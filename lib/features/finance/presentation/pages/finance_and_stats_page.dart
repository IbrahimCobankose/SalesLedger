import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/core/utils/excel_exporter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/core/widgets/main_top_bar.dart';
import 'package:sales_ledger/features/finance/presentation/providers/finance_provider.dart';
import 'package:sales_ledger/features/finance/presentation/widgets/period_selector.dart';
import 'package:sales_ledger/features/finance/presentation/widgets/product_performance_list.dart';
import 'package:sales_ledger/features/finance/presentation/widgets/stat_chart.dart';
import 'package:sales_ledger/features/finance/presentation/widgets/summary_card.dart';

/// kasa_ve_istatistikler.html taslağına karşılık gelen Finans sekmesi.
class FinanceAndStatsPage extends ConsumerWidget {
  const FinanceAndStatsPage({super.key});

  Future<void> _exportReport(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final summary = ref.read(financeSummaryProvider).valueOrNull;
    final chart = ref.read(chartDataProvider).valueOrNull;
    final period = ref.read(financePeriodProvider);

    if (summary == null || chart == null) {
      CustomSnackbar.show(context, message: l10n.financeReportNotReady, isError: true);
      return;
    }

    try {
      final path = await ExcelExporter.exportFinanceSummary(
        periodLabel: periodLabel(l10n, period),
        summary: summary,
        chartData: chart,
      );
      if (context.mounted) {
        CustomSnackbar.show(context, message: l10n.financeReportExportSuccess(path), isError: false);
      }
    } catch (_) {
      if (context.mounted) {
        CustomSnackbar.show(context, message: l10n.financeReportFailed, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final period = ref.watch(financePeriodProvider);
    final summaryAsync = ref.watch(financeSummaryProvider);
    final chartAsync = ref.watch(chartDataProvider);
    final topSellingAsync = ref.watch(topSellingProductsProvider);
    final topRevenueAsync = ref.watch(topRevenueProductsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const MainTopBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(financeSummaryProvider);
          ref.invalidate(chartDataProvider);
          ref.invalidate(topSellingProductsProvider);
          ref.invalidate(topRevenueProductsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.financeTitle, style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        l10n.financeSubtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _exportReport(context, ref),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: Text(l10n.financeReportButton),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PeriodSelector(
                selected: period,
                onChanged: (value) => ref.read(financePeriodProvider.notifier).select(value),
              ),
              const SizedBox(height: 16),
              summaryAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Text(l10n.financeSummaryFailed),
                data: (summary) => Column(
                  children: [
                    NetProfitCard(
                      netProfit: summary.netProfit,
                      changePercent: summary.changePercentVsPreviousPeriod,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SummaryStatCard(
                            label: l10n.financeTotalIncome,
                            amount: summary.totalIncome,
                            icon: Icons.arrow_downward,
                            accentColor: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryStatCard(
                            label: l10n.financeTotalExpense,
                            amount: summary.totalExpense,
                            icon: Icons.arrow_upward,
                            accentColor: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.push(AppRoutes.cashMovements),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long_outlined, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.financeViewCashMovements,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.financeChartTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    chartAsync.when(
                      loading: () => const SizedBox(
                        height: 192,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => Text(l10n.financeChartFailed),
                      data: (points) => StatChart(points: points),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              topSellingAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (error, _) => const SizedBox.shrink(),
                data: (products) => ProductPerformanceList(
                  title: l10n.financeTopSelling,
                  products: products,
                  valueBuilder: (p) => l10n.commonUnitsCount(p.quantitySold),
                ),
              ),
              const SizedBox(height: 12),
              topRevenueAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (error, _) => const SizedBox.shrink(),
                data: (products) => ProductPerformanceList(
                  title: l10n.financeTopRevenue,
                  products: products,
                  valueBuilder: (p) => '₺${p.revenue.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
