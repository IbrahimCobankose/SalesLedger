import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/features/finance/domain/entities/cash_movement.dart';
import 'package:sales_ledger/features/finance/domain/entities/cash_movement_query.dart';
import 'package:sales_ledger/features/finance/domain/entities/cash_overview.dart';
import 'package:sales_ledger/features/finance/domain/entities/chart_point.dart';
import 'package:sales_ledger/features/finance/domain/entities/finance_period.dart';
import 'package:sales_ledger/features/finance/domain/entities/finance_summary.dart';
import 'package:sales_ledger/features/finance/domain/entities/product_performance.dart';

/// Kasa ve istatistik raporlama işlemleri için soyut sözleşme.
abstract class FinanceRepository {
  Future<FinanceSummary> getSummary(FinancePeriod period, DateTime reference);

  Future<List<ChartPoint>> getChartData(FinancePeriod period, DateTime reference);

  Future<List<ProductPerformance>> getTopSellingProducts(
    FinancePeriod period,
    DateTime reference, {
    int limit = AppLimits.topProductListLimit,
  });

  Future<List<ProductPerformance>> getTopRevenueProducts(
    FinancePeriod period,
    DateTime reference, {
    int limit = AppLimits.topProductListLimit,
  });

  Future<CashOverview> getCashOverview();

  Future<List<CashMovement>> getCashMovements(CashMovementQuery query);
}
