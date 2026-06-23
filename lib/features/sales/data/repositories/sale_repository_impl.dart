import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_datasource.dart';
import 'package:sales_ledger/features/sales/data/datasources/sale_datasource.dart';
import 'package:sales_ledger/features/sales/data/models/sale_model.dart';
import 'package:sales_ledger/features/sales/domain/entities/cargo_status.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item_draft.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_query.dart';
import 'package:sales_ledger/features/sales/domain/repositories/sale_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleRepositoryImpl implements SaleRepository {
  SaleRepositoryImpl(this._datasource, this._authDatasource);

  final SaleDatasource _datasource;
  final AuthDatasource _authDatasource;

  @override
  Future<List<Sale>> getSales(SaleQuery query) async {
    try {
      return await _datasource.getSales(_authDatasource.currentUserId, query);
    } on PostgrestException {
      throw const AppException('Satışlar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<Sale> getSaleById(String id) async {
    try {
      return await _datasource.getSaleById(id);
    } on PostgrestException {
      throw const AppException('Satış bulunamadı.');
    }
  }

  @override
  Future<List<SaleItem>> getSaleItems(String saleId) async {
    try {
      return await _datasource.getSaleItems(saleId);
    } on PostgrestException {
      throw const AppException('Ürün kalemleri yüklenemedi.');
    }
  }

  @override
  Future<Sale> addSale({
    String? customerName,
    required DateTime saleDate,
    String? platform,
    required List<SaleItemDraft> items,
    CargoStatus status = CargoStatus.packaging,
    String? trackingNumber,
    String? notes,
  }) async {
    try {
      final userId = _authDatasource.currentUserId;
      final totalAmount = items.fold<double>(0, (sum, item) => sum + item.lineTotal);

      String? customerId;
      if (customerName != null && customerName.trim().isNotEmpty) {
        customerId = await _datasource.findOrCreateCustomer(userId: userId, name: customerName);
      }

      final draft = SaleModel(
        id: '',
        userId: userId,
        customerId: customerId,
        customerName: customerName,
        saleDate: saleDate,
        platform: platform,
        notes: notes,
        status: status,
        trackingNumber: trackingNumber,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
      );

      return await _datasource.insertSale(sale: draft, items: items);
    } on PostgrestException {
      throw const AppException('Satış kaydedilemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<Sale> updateSale({
    required String saleId,
    String? customerName,
    required DateTime saleDate,
    String? platform,
    required List<SaleItemDraft> items,
    CargoStatus status = CargoStatus.packaging,
    String? trackingNumber,
    String? notes,
  }) async {
    try {
      final userId = _authDatasource.currentUserId;
      final totalAmount = items.fold<double>(0, (sum, item) => sum + item.lineTotal);

      String? customerId;
      if (customerName != null && customerName.trim().isNotEmpty) {
        customerId = await _datasource.findOrCreateCustomer(userId: userId, name: customerName);
      }

      final model = SaleModel(
        id: saleId,
        userId: userId,
        customerId: customerId,
        customerName: customerName,
        saleDate: saleDate,
        platform: platform,
        notes: notes,
        status: status,
        trackingNumber: trackingNumber,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
      );

      return await _datasource.updateSale(saleId: saleId, sale: model, items: items);
    } on PostgrestException {
      throw const AppException('Satış güncellenemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<void> deleteSale(String id) async {
    try {
      await _datasource.deleteSale(id);
    } on PostgrestException {
      throw const AppException('Satış silinemedi. Lütfen tekrar deneyin.');
    }
  }
}
