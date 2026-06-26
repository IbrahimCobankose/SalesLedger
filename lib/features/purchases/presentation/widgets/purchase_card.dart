import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase.dart';
import 'package:sales_ledger/features/purchases/presentation/widgets/purchase_status_badge.dart';

const _months = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

String formatTurkishDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]} ${date.year}';
}

/// alımlar.html taslağındaki alış kartı.
class PurchaseCard extends StatelessWidget {
  const PurchaseCard({super.key, required this.purchase, required this.onTap});

  final Purchase purchase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
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
                          purchase.displaySupplierName,
                          style: textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatTurkishDate(purchase.purchaseDate),
                          style: textTheme.bodySmall,
                        ),
                        if (purchase.profileName != null && purchase.profileName!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 12, color: colorScheme.outline),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  purchase.profileName!,
                                  style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  PurchaseStatusBadge(status: purchase.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.purchaseCardItemCount(purchase.itemCount),
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(context.l10n.commonTotalAmount, style: textTheme.labelSmall),
                      Text(
                        '₺${purchase.totalAmount.toStringAsFixed(2)}',
                        style: textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
