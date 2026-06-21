import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_datasource.dart';
import 'package:sales_ledger/features/finance/data/datasources/finance_datasource.dart';
import 'package:sales_ledger/features/finance/domain/entities/cash_movement.dart';
import 'package:sales_ledger/features/finance/domain/entities/cash_movement_query.dart';
import 'package:sales_ledger/features/finance/domain/entities/cash_overview.dart';
import 'package:sales_ledger/features/finance/domain/entities/chart_point.dart';
import 'package:sales_ledger/features/finance/domain/entities/finance_period.dart';
import 'package:sales_ledger/features/finance/domain/entities/finance_summary.dart';
import 'package:sales_ledger/features/finance/domain/entities/product_performance.dart';
import 'package:sales_ledger/features/finance/domain/repositories/finance_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl(this._datasource, this._authDatasource);

  final FinanceDatasource _datasource;
  final AuthDatasource _authDatasource;

  double _sumAmount(List<Map<String, dynamic>> rows) {
    return rows.fold<double>(0, (sum, row) => sum + ((row['total_amount'] as num?)?.toDouble() ?? 0));
  }

  @override
  Future<FinanceSummary> getSummary(FinancePeriod period, DateTime reference) async {
    try {
      final userId = _authDatasource.currentUserId;
      final current = period.rangeFor(reference);
      final previous = period.previousRangeFor(reference);

      final currentSales = await _datasource.fetchCompletedSales(userId, current.start, current.end);
      final currentPurchases = await _datasource.fetchPurchases(userId, current.start, current.end);
      final previousSales = await _datasource.fetchCompletedSales(userId, previous.start, previous.end);
      final previousPurchases = await _datasource.fetchPurchases(userId, previous.start, previous.end);

      return FinanceSummary(
        totalIncome: _sumAmount(currentSales),
        totalExpense: _sumAmount(currentPurchases),
        previousNetProfit: _sumAmount(previousSales) - _sumAmount(previousPurchases),
      );
    } on PostgrestException {
      throw const AppException('Kasa özeti yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<List<ChartPoint>> getChartData(FinancePeriod period, DateTime reference) async {
    try {
      final userId = _authDatasource.currentUserId;
      final range = period.rangeFor(reference);
      final bucketCount = period.bucketCount;
      final bucketDuration = range.end.difference(range.start) ~/ bucketCount;

      final sales = await _datasource.fetchCompletedSales(userId, range.start, range.end);
      final purchases = await _datasource.fetchPurchases(userId, range.start, range.end);

      final points = <ChartPoint>[];
      for (var i = 0; i < bucketCount; i++) {
        final bucketStart = range.start.add(bucketDuration * i);
        final bucketEnd = i == bucketCount - 1 ? range.end : bucketStart.add(bucketDuration);

        final income = _sumAmount(sales
            .where((row) => _inRange(DateTime.parse(row['sale_date'] as String), bucketStart, bucketEnd))
            .toList());
        final expense = _sumAmount(purchases
            .where((row) =>
                _inRange(DateTime.parse(row['purchase_date'] as String), bucketStart, bucketEnd))
            .toList());

        points.add(ChartPoint(label: _bucketLabel(period, i), income: income, expense: expense));
      }

      return points;
    } on PostgrestException {
      throw const AppException('Grafik verisi yüklenemedi.');
    }
  }

  bool _inRange(DateTime value, DateTime start, DateTime end) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  String _bucketLabel(FinancePeriod period, int index) {
    switch (period) {
      case FinancePeriod.daily:
        return 'Bugün';
      case FinancePeriod.weekly:
        const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
        return days[index];
      case FinancePeriod.monthly:
        return 'H${index + 1}';
      case FinancePeriod.yearly:
        const months = [
          'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
        ];
        return months[index];
    }
  }

  List<ProductPerformance> _aggregateProducts(List<Map<String, dynamic>> items) {
    final aggregates = <String, ({int quantity, double revenue})>{};

    for (final row in items) {
      final name = row['name'] as String;
      final quantity = row['quantity'] as int? ?? 1;
      final unitPrice = (row['custom_sale_price'] as num).toDouble();
      final existing = aggregates[name];

      aggregates[name] = (
        quantity: (existing?.quantity ?? 0) + quantity,
        revenue: (existing?.revenue ?? 0) + unitPrice * quantity,
      );
    }

    return aggregates.entries
        .map((entry) => ProductPerformance(
              productName: entry.key,
              quantitySold: entry.value.quantity,
              revenue: entry.value.revenue,
            ))
        .toList();
  }

  @override
  Future<List<ProductPerformance>> getTopSellingProducts(
    FinancePeriod period,
    DateTime reference, {
    int limit = AppLimits.topProductListLimit,
  }) async {
    try {
      final userId = _authDatasource.currentUserId;
      final range = period.rangeFor(reference);
      final items = await _datasource.fetchCompletedSaleItems(userId, range.start, range.end);
      final products = _aggregateProducts(items)
        ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
      return products.take(limit).toList();
    } on PostgrestException {
      throw const AppException('Ürün istatistikleri yüklenemedi.');
    }
  }

  @override
  Future<List<ProductPerformance>> getTopRevenueProducts(
    FinancePeriod period,
    DateTime reference, {
    int limit = AppLimits.topProductListLimit,
  }) async {
    try {
      final userId = _authDatasource.currentUserId;
      final range = period.rangeFor(reference);
      final items = await _datasource.fetchCompletedSaleItems(userId, range.start, range.end);
      final products = _aggregateProducts(items)..sort((a, b) => b.revenue.compareTo(a.revenue));
      return products.take(limit).toList();
    } on PostgrestException {
      throw const AppException('Ürün istatistikleri yüklenemedi.');
    }
  }

  @override
  Future<CashOverview> getCashOverview() async {
    try {
      final userId = _authDatasource.currentUserId;
      final monthRange = FinancePeriod.monthly.rangeFor(DateTime.now());
      final epoch = DateTime.fromMillisecondsSinceEpoch(0);
      final farFuture = DateTime(2100);

      final allSales = await _datasource.fetchCompletedSales(userId, epoch, farFuture);
      final allPurchases = await _datasource.fetchPurchases(userId, epoch, farFuture);
      final monthSales =
          await _datasource.fetchCompletedSales(userId, monthRange.start, monthRange.end);
      final monthPurchases =
          await _datasource.fetchPurchases(userId, monthRange.start, monthRange.end);

      return CashOverview(
        totalBalance: _sumAmount(allSales) - _sumAmount(allPurchases),
        monthIncome: _sumAmount(monthSales),
        monthExpense: _sumAmount(monthPurchases),
      );
    } on PostgrestException {
      throw const AppException('Kasa özeti yüklenemedi.');
    }
  }

  @override
  Future<List<CashMovement>> getCashMovements(CashMovementQuery query) async {
    try {
      final userId = _authDatasource.currentUserId;
      final start = query.startDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final end = query.endDate ?? DateTime(2100);

      final movements = <CashMovement>[];

      if (query.typeFilter != CashMovementType.expense) {
        final sales = await _datasource.fetchCompletedSales(userId, start, end);
        movements.addAll(sales.map((row) {
          final customer = row['customers'] as Map<String, dynamic>?;
          final title = (customer?['name'] as String?) ??
              (row['platform'] as String?) ??
              'Satış';
          return CashMovement(
            id: row['id'] as String,
            type: CashMovementType.income,
            title: title,
            amount: (row['total_amount'] as num?)?.toDouble() ?? 0,
            date: DateTime.parse(row['sale_date'] as String),
          );
        }));
      }

      if (query.typeFilter != CashMovementType.income) {
        final purchases = await _datasource.fetchPurchases(userId, start, end);
        movements.addAll(purchases.map((row) {
          return CashMovement(
            id: row['id'] as String,
            type: CashMovementType.expense,
            title: (row['supplier_name'] as String?) ?? 'Alış',
            amount: (row['total_amount'] as num?)?.toDouble() ?? 0,
            date: DateTime.parse(row['purchase_date'] as String),
          );
        }));
      }

      movements.sort((a, b) => b.date.compareTo(a.date));
      return movements;
    } on PostgrestException {
      throw const AppException('Kasa hareketleri yüklenemedi.');
    }
  }
}
