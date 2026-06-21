import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_datasource.dart';
import 'package:sales_ledger/features/purchases/data/datasources/purchase_datasource.dart';
import 'package:sales_ledger/features/purchases/data/models/purchase_model.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item_draft.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_query.dart';
import 'package:sales_ledger/features/purchases/domain/repositories/purchase_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl(this._datasource, this._authDatasource);

  final PurchaseDatasource _datasource;
  final AuthDatasource _authDatasource;

  @override
  Future<List<Purchase>> getPurchases(PurchaseQuery query) async {
    try {
      return await _datasource.getPurchases(_authDatasource.currentUserId, query);
    } on PostgrestException {
      throw const AppException('Alışlar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<Purchase> getPurchaseById(String id) async {
    try {
      return await _datasource.getPurchaseById(id);
    } on PostgrestException {
      throw const AppException('Alış bulunamadı.');
    }
  }

  @override
  Future<List<PurchaseItem>> getPurchaseItems(String purchaseId) async {
    try {
      return await _datasource.getPurchaseItems(purchaseId);
    } on PostgrestException {
      throw const AppException('Ürün kalemleri yüklenemedi.');
    }
  }

  @override
  Future<Purchase> addPurchase({
    String? supplierName,
    required DateTime purchaseDate,
    required List<PurchaseItemDraft> items,
    String? paymentType,
    String? notes,
  }) async {
    try {
      final totalAmount = items.fold<double>(0, (sum, item) => sum + item.lineTotal);

      final draft = PurchaseModel(
        id: '',
        userId: _authDatasource.currentUserId,
        supplierName: supplierName,
        purchaseDate: purchaseDate,
        notes: notes,
        paymentType: paymentType,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
      );

      return await _datasource.insertPurchase(purchase: draft, items: items);
    } on PostgrestException {
      throw const AppException('Alış kaydedilemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<void> deletePurchase(String id) async {
    try {
      await _datasource.deletePurchase(id);
    } on PostgrestException {
      throw const AppException('Alış silinemedi. Lütfen tekrar deneyin.');
    }
  }
}
