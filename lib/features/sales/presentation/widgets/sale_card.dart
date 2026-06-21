import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale.dart';
import 'package:sales_ledger/features/sales/presentation/widgets/cargo_status_badge.dart';

const _months = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

String formatTurkishDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]} ${date.year}';
}

/// satışlar.html taslağındaki satış kartı. [UI] İptal edilmiş satışlar
/// soluk (opacity 0.75) ve başlık üstü çizili gösterilir (gereksinim 4.3.1).
class SaleCard extends StatelessWidget {
  const SaleCard({super.key, required this.sale, required this.onTap});

  final Sale sale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canceled = sale.isCanceled;

    final dateLabel = sale.platform != null && sale.platform!.isNotEmpty
        ? '${formatTurkishDate(sale.saleDate)} • ${sale.platform}'
        : formatTurkishDate(sale.saleDate);

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.displayTitle,
                      style: textTheme.titleLarge?.copyWith(
                        decoration: canceled ? TextDecoration.lineThrough : null,
                        color: canceled ? colorScheme.outline : colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(dateLabel, style: textTheme.bodySmall),
                  ],
                ),
              ),
              Text(
                '₺${sale.totalAmount.toStringAsFixed(2)}',
                style: textTheme.headlineSmall?.copyWith(
                  color: canceled ? colorScheme.outline : colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: colorScheme.surfaceContainerHigh),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(context.l10n.saleCardItemCount(sale.itemCount), style: textTheme.bodySmall),
                ],
              ),
              CargoStatusBadge(status: sale.status),
            ],
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(opacity: canceled ? 0.75 : 1, child: card),
      ),
    );
  }
}
