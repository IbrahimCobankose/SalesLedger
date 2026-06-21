import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/gen/app_localizations.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/features/finance/domain/entities/finance_period.dart';

/// [FinancePeriod] etiketleri, domain'deki Türkçe `.label` yerine burada
/// yerelleştirilir.
String periodLabel(AppLocalizations l10n, FinancePeriod period) {
  switch (period) {
    case FinancePeriod.daily:
      return l10n.financePeriodDaily;
    case FinancePeriod.weekly:
      return l10n.financePeriodWeekly;
    case FinancePeriod.monthly:
      return l10n.financePeriodMonthly;
    case FinancePeriod.yearly:
      return l10n.financePeriodYearly;
  }
}

/// kasa_ve_istatistikler.html taslağındaki segmented periyot seçici.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key, required this.selected, required this.onChanged});

  final FinancePeriod selected;
  final ValueChanged<FinancePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: FinancePeriod.values.map((period) {
          final isSelected = period == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 2)]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  periodLabel(l10n, period),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
