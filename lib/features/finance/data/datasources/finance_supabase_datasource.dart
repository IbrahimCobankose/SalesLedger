import 'package:sales_ledger/features/finance/data/datasources/finance_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceSupabaseDatasource implements FinanceDatasource {
  FinanceSupabaseDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchCompletedSales(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _client
        .from('sales')
        .select('id, sale_date, total_amount, platform, customers(name)')
        .eq('user_id', userId)
        .eq('status', 'completed')
        .gte('sale_date', start.toIso8601String())
        .lt('sale_date', end.toIso8601String());

    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPurchases(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _client
        .from('purchases')
        .select('id, purchase_date, total_amount, supplier_name')
        .eq('user_id', userId)
        .gte('purchase_date', start.toIso8601String())
        .lt('purchase_date', end.toIso8601String());

    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCompletedSaleItems(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _client
        .from('sale_items')
        .select('name, quantity, custom_sale_price, sales!inner(sale_date, status, user_id)')
        .eq('sales.user_id', userId)
        .eq('sales.status', 'completed')
        .gte('sales.sale_date', start.toIso8601String())
        .lt('sales.sale_date', end.toIso8601String());

    return List<Map<String, dynamic>>.from(rows);
  }
}
