import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/features/finance/domain/entities/chart_point.dart';

/// kasa_ve_istatistikler.html taslağındaki Gelir/Gider çubuk grafiği.
/// Gelir = primary (mavi), gider = error (kırmızı) — gereksinim 4.5.1.
class StatChart extends StatelessWidget {
  const StatChart({super.key, required this.points});

  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (points.isEmpty) {
      return SizedBox(height: 192, child: Center(child: Text(context.l10n.financeNoDataForChart)));
    }

    final maxValue = points
        .map((p) => p.income > p.expense ? p.income : p.expense)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return Column(
      children: [
        SizedBox(
          height: 192,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: points.map((point) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Bar(
                        heightFraction: point.income / safeMax,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      _Bar(
                        heightFraction: point.expense / safeMax,
                        color: colorScheme.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(point.label, style: textTheme.labelSmall),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: colorScheme.primary, label: context.l10n.financeIncomeLegend),
            const SizedBox(width: 16),
            _LegendDot(color: colorScheme.error, label: context.l10n.financeExpenseLegend),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.heightFraction, required this.color});

  final double heightFraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const maxBarHeight = 150.0;
    return Container(
      width: 14,
      height: (heightFraction.clamp(0, 1) * maxBarHeight) + 2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
