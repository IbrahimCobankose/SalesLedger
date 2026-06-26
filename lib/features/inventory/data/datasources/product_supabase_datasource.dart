import 'dart:typed_data';

import 'package:sales_ledger/core/storage/storage_buckets.dart';
import 'package:sales_ledger/features/inventory/data/datasources/product_datasource.dart';
import 'package:sales_ledger/features/inventory/data/models/product_model.dart';
import 'package:sales_ledger/features/inventory/data/models/product_sale_history_item_model.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_query.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductSupabaseDatasource implements ProductDatasource {
  ProductSupabaseDatasource(this._client);

  final SupabaseClient _client;
  static const _photoBucket = StorageBuckets.productPhotos;

  @override
  Future<List<ProductModel>> getProducts(String userId, ProductQuery query) async {
    var builder = _client.from('products').select().eq('user_id', userId);

    if (query.search.trim().isNotEmpty) {
      final term = query.search.trim();
      builder = builder.or('name.ilike.%$term%,description.ilike.%$term%');
    }
    if (query.category != null && query.category!.isNotEmpty) {
      builder = builder.eq('category', query.category!);
    }
    switch (query.stockFilter) {
      case StockFilter.inStock:
        builder = builder.gt('stock_quantity', 0);
      case StockFilter.outOfStock:
        builder = builder.eq('stock_quantity', 0);
      case StockFilter.all:
        break;
    }
    if (query.favoritesOnly) {
      builder = builder.eq('is_favorite', true);
    }

    final from = query.page * query.pageSize;
    final to = from + query.pageSize - 1;

    final PostgrestTransformBuilder<PostgrestList> ordered;
    switch (query.sort) {
      case ProductSortOption.priceDescending:
        ordered = builder.order('sale_price', ascending: false);
      case ProductSortOption.priceAscending:
        ordered = builder.order('sale_price', ascending: true);
      case ProductSortOption.bestSelling:
        ordered = builder.order('sold_count', ascending: false);
      case ProductSortOption.alphabetical:
        ordered = builder.order('name', ascending: true);
    }

    final rows = await ordered.range(from, to);
    return rows.map((row) => ProductModel.fromJson(row)).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final row = await _client.from('products').select().eq('id', id).single();
    return ProductModel.fromJson(row);
  }

  @override
  Future<ProductModel> insertProduct(ProductModel product) async {
    final row = await _client.from('products').insert(product.toInsertJson()).select().single();
    return ProductModel.fromJson(row);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final row = await _client
        .from('products')
        .update(product.toJson())
        .eq('id', product.id)
        .select()
        .single();
    return ProductModel.fromJson(row);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  @override
  Future<void> setFavorite(String id, bool value) async {
    await _client.from('products').update({'is_favorite': value}).eq('id', id);
  }

  @override
  Future<List<String>> uploadPhotos({
    required String userId,
    required List<Uint8List> photos,
  }) async {
    // Bucket gizli olduğundan public URL üretilmez; DB'de bucket içi göreli
    // path saklanır ve görüntülemede imzalı URL'ye çevrilir.
    final paths = <String>[];
    for (final photo in photos) {
      final path = '$userId/${DateTime.now().microsecondsSinceEpoch}_${paths.length}.jpg';
      await _client.storage.from(_photoBucket).uploadBinary(path, photo);
      paths.add(path);
    }
    return paths;
  }

  @override
  Future<void> deletePhotos(List<String> photoPaths) async {
    final paths = photoPaths.map((v) => storagePathFromValue(v, _photoBucket)).toList();
    if (paths.isNotEmpty) {
      await _client.storage.from(_photoBucket).remove(paths);
    }
  }

  @override
  Future<List<ProductSaleHistoryItemModel>> getSaleHistory(String productId) async {
    final rows = await _client
        .from('sale_items')
        .select('quantity, custom_sale_price, sales!inner(id, sale_date, status)')
        .eq('product_id', productId)
        .order('sale_id', ascending: false);

    return rows.map((row) => ProductSaleHistoryItemModel.fromJson(row)).toList();
  }
}
