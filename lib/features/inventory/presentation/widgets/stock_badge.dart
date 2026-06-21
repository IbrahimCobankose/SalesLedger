import 'package:flutter/material.dart';
import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';

/// envanter.html taslağındaki stok durum rozeti. Eşikler:
/// 0 → "Tükendi" (kırmızı), 1-5 → düşük stok (turuncu), 6+ → normal (yeşil).
class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.stockQuantity});

  final int stockQuantity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    late Color background;
    late Color foreground;
    late String label;

    if (stockQuantity <= 0) {
      background = colorScheme.errorContainer;
      foreground = colorScheme.onErrorContainer;
      label = context.l10n.inventoryOutOfStockBadge;
    } else if (stockQuantity <= AppLimits.lowStockThreshold) {
      background = const Color(0xFFFFF3E0);
      foreground = const Color(0xFFE65100);
      label = context.l10n.commonUnitsCount(stockQuantity);
    } else {
      background = const Color(0xFFE8F5E9);
      foreground = const Color(0xFF2E7D32);
      label = context.l10n.commonUnitsCount(stockQuantity);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(4)),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
