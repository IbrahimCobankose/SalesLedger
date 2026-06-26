import 'dart:typed_data';

import 'package:sales_ledger/core/storage/storage_buckets.dart';
import 'package:sales_ledger/features/purchases/data/datasources/purchase_datasource.dart';
import 'package:sales_ledger/features/purchases/data/models/purchase_item_model.dart';
import 'package:sales_ledger/features/purchases/data/models/purchase_model.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item_draft.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_query.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseSupabaseDatasource implements PurchaseDatasource {
  PurchaseSupabaseDatasource(this._client);

  final SupabaseClient _client;
  static const _photoBucket = StorageBuckets.purchasePhotos;

  @override
  Future<List<String>> uploadPhotos({
    required String userId,
    required List<Uint8List> photos,
  }) async {
    // Bucket gizli olduğundan DB'de bucket içi göreli path saklanır.
    final paths = <String>[];
    for (final photo in photos) {
      final path = '$userId/${DateTime.now().microsecondsSinceEpoch}_${paths.length}.jpg';
      await _client.storage.from(_photoBucket).uploadBinary(path, photo);
      paths.add(path);
    }
    return paths;
  }

  @override
  Future<List<PurchaseModel>> getPurchases(String userId, PurchaseQuery query) async {
    var builder = _client
        .from('purchases')
        .select('*, purchase_items(count)')
        .eq('user_id', userId);

    if (query.search.trim().isNotEmpty) {
      final term = query.search.trim();
      builder = builder.or('supplier_name.ilike.%$term%,description.ilike.%$term%');
    }

    final dbStatuses = query.statusFilter.dbStatuses;
    if (dbStatuses != null) {
      builder = builder.inFilter('status', dbStatuses.map((status) => status.dbValue).toList());
    }

    final from = query.page * query.pageSize;
    final to = from + query.pageSize - 1;

    final rows = await builder.order('purchase_date', ascending: false).range(from, to);
    return rows.map((row) => PurchaseModel.fromJson(row)).toList();
  }

  @override
  Future<PurchaseModel> getPurchaseById(String id) async {
    final row = await _client
        .from('purchases')
        .select('*, purchase_items(count)')
        .eq('id', id)
        .single();
    return PurchaseModel.fromJson(row);
  }

  @override
  Future<List<PurchaseItemModel>> getPurchaseItems(String purchaseId) async {
    final rows =
        await _client.from('purchase_items').select().eq('purchase_id', purchaseId);
    return rows.map((row) => PurchaseItemModel.fromJson(row)).toList();
  }

  @override
  Future<PurchaseModel> insertPurchase({
    required PurchaseModel purchase,
    required List<PurchaseItemDraft> items,
  }) async {
    final purchaseRow =
        await _client.from('purchases').insert(purchase.toInsertJson()).select().single();
    final inserted = PurchaseModel.fromJson(purchaseRow);

    if (items.isNotEmpty) {
      await _client.from('purchase_items').insert(
            items
                .map((item) => {
                      'purchase_id': inserted.id,
                      'product_id': item.productId,
                      'name': item.name,
                      'custom_purchase_price': item.unitPrice,
                      'quantity': item.quantity,
                    })
                .toList(),
          );
    }

    return PurchaseModel(
      id: inserted.id,
      userId: inserted.userId,
      supplierId: inserted.supplierId,
      supplierName: inserted.supplierName,
      purchaseDate: inserted.purchaseDate,
      description: inserted.description,
      notes: inserted.notes,
      status: inserted.status,
      trackingNumber: inserted.trackingNumber,
      paymentType: inserted.paymentType,
      totalAmount: inserted.totalAmount,
      itemCount: items.length,
      photos: inserted.photos,
      createdAt: inserted.createdAt,
    );
  }

  @override
  Future<void> deletePhotos(List<String> photoPaths) async {
    final paths = photoPaths.map((v) => storagePathFromValue(v, _photoBucket)).toList();
    if (paths.isNotEmpty) {
      await _client.storage.from(_photoBucket).remove(paths);
    }
  }

  @override
  Future<void> deletePurchase(String id) async {
    await _client.from('purchases').delete().eq('id', id);
  }
}
