import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';

/// kasa_ve_istatistikler.html taslağındaki tam genişlikli Net Kâr kartı.
/// [changePercent] null ise (önceki dönem verisi yoksa) trend satırı
/// gösterilmez.
class NetProfitCard extends StatelessWidget {
  const NetProfitCard({super.key, required this.netProfit, required this.changePercent});

  final double netProfit;
  final double? changePercent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.financeNetProfit,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.9)),
              ),
              Icon(Icons.account_balance_wallet, color: colorScheme.onPrimary.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '₺${netProfit.toStringAsFixed(2)}',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
          ),
          if (changePercent != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  changePercent! >= 0 ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: colorScheme.primaryFixed,
                ),
                const SizedBox(width: 4),
                Text(
                  context.l10n.financeChangeVsPrevious(
                    '${changePercent! >= 0 ? '+' : ''}${changePercent!.toStringAsFixed(0)}%',
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.primaryFixed),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Toplam Gelir / Toplam Gider mini kartları (yan yana, gereksinim 4.5.1).
class SummaryStatCard extends StatelessWidget {
  const SummaryStatCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('₺${amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}
