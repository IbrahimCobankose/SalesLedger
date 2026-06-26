import 'package:sales_ledger/features/sales/data/datasources/sale_datasource.dart';
import 'package:sales_ledger/features/sales/data/models/sale_item_model.dart';
import 'package:sales_ledger/features/sales/data/models/sale_model.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item_draft.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_query.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleSupabaseDatasource implements SaleDatasource {
  SaleSupabaseDatasource(this._client);

  final SupabaseClient _client;

  static const _selectWithRelations = '*, customers(name), sale_items(name), profiles(name)';

  @override
  Future<List<SaleModel>> getSales(String userId, SaleQuery query) async {
    var builder = _client.from('sales').select(_selectWithRelations).eq('user_id', userId);

    if (query.search.trim().isNotEmpty) {
      final term = query.search.trim();
      builder = builder.or('platform.ilike.%$term%,description.ilike.%$term%');
    }

    final status = query.statusFilter.dbStatus;
    if (status != null) {
      builder = builder.eq('status', status.dbValue);
    }

    if (query.profileId != null) {
      builder = builder.eq('profile_id', query.profileId!);
    }

    final from = query.page * query.pageSize;
    final to = from + query.pageSize - 1;

    final ordered = builder.order(
      'sale_date',
      ascending: query.sort == SaleSortOption.dateAscending,
    );

    final rows = await ordered.range(from, to);
    return rows.map((row) => SaleModel.fromJson(row)).toList();
  }

  @override
  Future<SaleModel> getSaleById(String id) async {
    final row = await _client.from('sales').select(_selectWithRelations).eq('id', id).single();
    return SaleModel.fromJson(row);
  }

  @override
  Future<List<SaleItemModel>> getSaleItems(String saleId) async {
    final rows = await _client.from('sale_items').select().eq('sale_id', saleId);
    return rows.map((row) => SaleItemModel.fromJson(row)).toList();
  }

  @override
  Future<String?> findOrCreateCustomer({required String userId, required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final existing = await _client
        .from('customers')
        .select('id')
        .eq('user_id', userId)
        .eq('name', trimmed)
        .limit(1);

    if (existing.isNotEmpty) {
      return existing.first['id'] as String;
    }

    final created =
        await _client.from('customers').insert({'user_id': userId, 'name': trimmed}).select().single();
    return created['id'] as String;
  }

  @override
  Future<SaleModel> insertSale({
    required SaleModel sale,
    required List<SaleItemDraft> items,
  }) async {
    final saleRow = await _client.from('sales').insert(sale.toInsertJson()).select().single();
    final inserted = SaleModel.fromJson(saleRow);

    if (items.isNotEmpty) {
      await _client.from('sale_items').insert(
            items
                .map((item) => {
                      'sale_id': inserted.id,
                      'product_id': item.productId,
                      'name': item.name,
                      'custom_sale_price': item.unitPrice,
                      'quantity': item.quantity,
                    })
                .toList(),
          );
    }

    return SaleModel(
      id: inserted.id,
      userId: inserted.userId,
      customerId: inserted.customerId,
      customerName: sale.customerName,
      saleDate: inserted.saleDate,
      platform: inserted.platform,
      description: inserted.description,
      notes: inserted.notes,
      status: inserted.status,
      trackingNumber: inserted.trackingNumber,
      totalAmount: inserted.totalAmount,
      itemCount: items.length,
      firstItemName: items.isNotEmpty ? items.first.name : null,
      profileId: inserted.profileId,
      profileName: sale.profileName,
      createdAt: inserted.createdAt,
    );
  }

  @override
  Future<SaleModel> updateSale({
    required String saleId,
    required SaleModel sale,
    required List<SaleItemDraft> items,
  }) async {
    await _client.from('sales').update(sale.toUpdateJson()).eq('id', saleId);

    // Kalemleri tamamen yenile: eskileri sil, yenilerini ekle.
    await _client.from('sale_items').delete().eq('sale_id', saleId);
    if (items.isNotEmpty) {
      await _client.from('sale_items').insert(
            items
                .map((item) => {
                      'sale_id': saleId,
                      'product_id': item.productId,
                      'name': item.name,
                      'custom_sale_price': item.unitPrice,
                      'quantity': item.quantity,
                    })
                .toList(),
          );
    }

    final row = await _client.from('sales').select(_selectWithRelations).eq('id', saleId).single();
    return SaleModel.fromJson(row);
  }

  @override
  Future<void> deleteSale(String id) async {
    await _client.from('sales').delete().eq('id', id);
  }
}
