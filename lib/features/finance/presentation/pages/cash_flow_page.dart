import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/features/finance/domain/entities/cash_movement.dart';
import 'package:sales_ledger/features/finance/presentation/providers/finance_provider.dart';
import 'package:sales_ledger/features/finance/presentation/widgets/cash_movement_tile.dart';

/// kasa_hareketleri.html taslağına karşılık gelen, Kasa ve İstatistikler
/// sayfasından erişilen detay sayfası (gereksinim 4.5.2).
class CashFlowPage extends ConsumerWidget {
  const CashFlowPage({super.key});

  Future<void> _showFilterSheet(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(cashMovementFilterProvider.notifier);
    final current = ref.read(cashMovementFilterProvider);
    final l10n = context.l10n;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.cashFlowMovementType, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.commonAll),
                      selected: current.typeFilter == null,
                      onSelected: (_) {
                        notifier.setTypeFilter(null);
                        Navigator.of(context).pop();
                      },
                    ),
                    ChoiceChip(
                      label: Text(l10n.cashFlowIncomeFilter),
                      selected: current.typeFilter == CashMovementType.income,
                      onSelected: (_) {
                        notifier.setTypeFilter(CashMovementType.income);
                        Navigator.of(context).pop();
                      },
                    ),
                    ChoiceChip(
                      label: Text(l10n.cashFlowExpenseFilter),
                      selected: current.typeFilter == CashMovementType.expense,
                      onSelected: (_) {
                        notifier.setTypeFilter(CashMovementType.expense);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (range != null) {
                      notifier.setDateRange(range.start, range.end);
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(l10n.cashFlowPickDateRange),
                ),
                if (current.startDate != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      notifier.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.cashFlowClearFilter),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final overviewAsync = ref.watch(cashOverviewProvider);
    final movementsAsync = ref.watch(cashMovementsProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.cashFlowTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              overviewAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Text(l10n.financeSummaryFailed),
                data: (overview) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.cashFlowTotalBalance,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.8)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₺${overview.totalBalance.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(color: colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: colorScheme.onPrimary.withValues(alpha: 0.2)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.cashFlowMonthIncome,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                                        ),
                                  ),
                                  Text(
                                    '+ ₺${overview.monthIncome.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(color: const Color(0xFFBBF7D0)),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 32, color: colorScheme.onPrimary.withValues(alpha: 0.2)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.cashFlowMonthExpense,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                                        ),
                                  ),
                                  Text(
                                    '- ₺${overview.monthExpense.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(color: const Color(0xFFFECACA)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.cashFlowRecentTransactions, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              movementsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Text(l10n.cashFlowLoadFailed),
                data: (movements) {
                  if (movements.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(l10n.cashFlowEmpty),
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < movements.length; i++) ...[
                          if (i > 0) Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                          CashMovementTile(
                            movement: movements[i],
                            onTap: () {
                              final movement = movements[i];
                              // Gelir bir satışa, gider bir alışa karşılık gelir;
                              // ilgili detay sayfasına götür.
                              if (movement.type == CashMovementType.income) {
                                context.push(AppRoutes.saleDetails(movement.id));
                              } else {
                                context.push(AppRoutes.purchaseDetails(movement.id));
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
