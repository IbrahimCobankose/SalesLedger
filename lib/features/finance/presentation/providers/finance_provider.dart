import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_ledger/core/network/supabase_client.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:sales_ledger/features/finance/data/datasources/finance_supabase_datasource.dart';
import 'package:sales_ledger/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:sales_ledger/features/finance/domain/entities/cash_movement.dart';
import 'package:sales_ledger/features/finance/domain/entities/cash_movement_query.dart';
import 'package:sales_ledger/features/finance/domain/entities/finance_period.dart';
import 'package:sales_ledger/features/finance/domain/repositories/finance_repository.dart';
import 'package:sales_ledger/features/finance/domain/usecases/get_cash_movements_usecase.dart';
import 'package:sales_ledger/features/finance/domain/usecases/get_cash_overview_usecase.dart';
import 'package:sales_ledger/features/finance/domain/usecases/get_chart_data_usecase.dart';
import 'package:sales_ledger/features/finance/domain/usecases/get_finance_summary_usecase.dart';
import 'package:sales_ledger/features/finance/domain/usecases/get_top_revenue_products_usecase.dart';
import 'package:sales_ledger/features/finance/domain/usecases/get_top_selling_products_usecase.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepositoryImpl(
    FinanceSupabaseDatasource(supabase),
    AuthSupabaseDatasource(supabase),
  );
});

final getFinanceSummaryUseCaseProvider = Provider(
  (ref) => GetFinanceSummaryUseCase(ref.watch(financeRepositoryProvider)),
);
final getChartDataUseCaseProvider = Provider(
  (ref) => GetChartDataUseCase(ref.watch(financeRepositoryProvider)),
);
final getTopSellingProductsUseCaseProvider = Provider(
  (ref) => GetTopSellingProductsUseCase(ref.watch(financeRepositoryProvider)),
);
final getTopRevenueProductsUseCaseProvider = Provider(
  (ref) => GetTopRevenueProductsUseCase(ref.watch(financeRepositoryProvider)),
);
final getCashOverviewUseCaseProvider = Provider(
  (ref) => GetCashOverviewUseCase(ref.watch(financeRepositoryProvider)),
);
final getCashMovementsUseCaseProvider = Provider(
  (ref) => GetCashMovementsUseCase(ref.watch(financeRepositoryProvider)),
);

/// Kasa ve İstatistikler ekranındaki periyot seçici durumu. Varsayılan
/// "Aylık" (gereksinim 4.5.1).
class FinancePeriodNotifier extends Notifier<FinancePeriod> {
  @override
  FinancePeriod build() => FinancePeriod.monthly;

  void select(FinancePeriod period) => state = period;
}

final financePeriodProvider = NotifierProvider<FinancePeriodNotifier, FinancePeriod>(
  FinancePeriodNotifier.new,
);

final financeSummaryProvider = FutureProvider.autoDispose((ref) {
  final period = ref.watch(financePeriodProvider);
  return ref.read(getFinanceSummaryUseCaseProvider)(period, DateTime.now());
});

final chartDataProvider = FutureProvider.autoDispose((ref) {
  final period = ref.watch(financePeriodProvider);
  return ref.read(getChartDataUseCaseProvider)(period, DateTime.now());
});

final topSellingProductsProvider = FutureProvider.autoDispose((ref) {
  final period = ref.watch(financePeriodProvider);
  return ref.read(getTopSellingProductsUseCaseProvider)(period, DateTime.now());
});

final topRevenueProductsProvider = FutureProvider.autoDispose((ref) {
  final period = ref.watch(financePeriodProvider);
  return ref.read(getTopRevenueProductsUseCaseProvider)(period, DateTime.now());
});

final cashOverviewProvider = FutureProvider.autoDispose((ref) {
  return ref.read(getCashOverviewUseCaseProvider)();
});

/// Kasa Hareketleri sayfasındaki tür/tarih filtresini tutar.
class CashMovementFilterNotifier extends Notifier<CashMovementQuery> {
  @override
  CashMovementQuery build() => const CashMovementQuery();

  void setTypeFilter(CashMovementType? type) =>
      state = state.copyWith(typeFilter: () => type);

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: () => start, endDate: () => end);
  }

  void clear() => state = const CashMovementQuery();
}

final cashMovementFilterProvider =
    NotifierProvider<CashMovementFilterNotifier, CashMovementQuery>(
  CashMovementFilterNotifier.new,
);

final cashMovementsProvider = FutureProvider.autoDispose((ref) {
  final query = ref.watch(cashMovementFilterProvider);
  return ref.read(getCashMovementsUseCaseProvider)(query);
});
