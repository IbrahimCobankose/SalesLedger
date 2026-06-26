import 'dart:typed_data';

import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_datasource.dart';
import 'package:sales_ledger/features/inventory/data/datasources/product_datasource.dart';
import 'package:sales_ledger/features/inventory/data/models/product_model.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_query.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_sale_history_item.dart';
import 'package:sales_ledger/features/inventory/domain/repositories/product_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._datasource, this._authDatasource);

  final ProductDatasource _datasource;
  final AuthDatasource _authDatasource;

  @override
  Future<List<Product>> getProducts(ProductQuery query) async {
    try {
      return await _datasource.getProducts(_authDatasource.currentUserId, query);
    } on PostgrestException {
      throw const AppException('Ürünler yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      return await _datasource.getProductById(id);
    } on PostgrestException {
      throw const AppException('Ürün bulunamadı.');
    }
  }

  @override
  Future<Product> addProduct({
    required String name,
    required double salePrice,
    required List<Uint8List> photos,
    double? productionCost,
    String? category,
    int initialStock = 0,
    double? length,
    double? width,
    double? height,
    double? weight,
    String? description,
    String? notes,
    List<String> tags = const [],
    String? profileId,
  }) async {
    try {
      final userId = _authDatasource.currentUserId;
      final photoUrls = await _datasource.uploadPhotos(userId: userId, photos: photos);

      final draft = ProductModel(
        id: '',
        userId: userId,
        name: name,
        salePrice: salePrice,
        productionCost: productionCost,
        length: length,
        width: width,
        height: height,
        weight: weight,
        description: description,
        stockQuantity: initialStock,
        notes: notes,
        photos: photoUrls,
        category: category,
        tags: tags,
        profileId: profileId,
        createdAt: DateTime.now(),
      );

      return await _datasource.insertProduct(draft);
    } on StorageException {
      throw const AppException('Fotoğraflar yüklenemedi. Lütfen tekrar deneyin.');
    } on PostgrestException {
      throw const AppException('Ürün kaydedilemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<Product> updateProduct(Product product, {List<Uint8List> newPhotos = const []}) async {
    try {
      final userId = _authDatasource.currentUserId;
      // Düzenleme öncesi fotoğrafları, sonradan kaldırılanları depolamadan
      // silebilmek için al.
      final original = await _datasource.getProductById(product.id);

      final uploaded = newPhotos.isEmpty
          ? const <String>[]
          : await _datasource.uploadPhotos(userId: userId, photos: newPhotos);
      final mergedPhotos = [...product.photos, ...uploaded];

      final updated = await _datasource.updateProduct(
        ProductModel.fromEntity(product.copyWith(photos: mergedPhotos)),
      );

      final removed =
          original.photos.where((url) => !mergedPhotos.contains(url)).toList();
      if (removed.isNotEmpty) {
        // En iyi çaba: depolama temizliği başarısız olsa da güncelleme geçerli.
        try {
          await _datasource.deletePhotos(removed);
        } catch (_) {}
      }

      return updated;
    } on StorageException {
      throw const AppException('Fotoğraflar yüklenemedi. Lütfen tekrar deneyin.');
    } on PostgrestException {
      throw const AppException('Ürün güncellenemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      // Önce fotoğraf URL'lerini al; satır silindikten sonra depolamayı temizle.
      List<String> photos = const [];
      try {
        photos = (await _datasource.getProductById(id)).photos;
      } catch (_) {}

      await _datasource.deleteProduct(id);

      if (photos.isNotEmpty) {
        try {
          await _datasource.deletePhotos(photos);
        } catch (_) {}
      }
    } on PostgrestException {
      throw const AppException('Ürün silinemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<void> setFavorite(String id, bool value) async {
    try {
      await _datasource.setFavorite(id, value);
    } on PostgrestException {
      throw const AppException('Favori durumu güncellenemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<List<ProductSaleHistoryItem>> getSaleHistory(String productId) async {
    try {
      return await _datasource.getSaleHistory(productId);
    } on PostgrestException {
      throw const AppException('Satış geçmişi yüklenemedi.');
    }
  }
}
