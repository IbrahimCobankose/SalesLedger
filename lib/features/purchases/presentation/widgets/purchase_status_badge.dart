import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_status.dart';

/// alımlar.html taslağındaki durum rozeti: Tamamlandı (yeşil),
/// Bekliyor (turuncu), İptal Edildi (kırmızı).
class PurchaseStatusBadge extends StatelessWidget {
  const PurchaseStatusBadge({super.key, required this.status});

  final PurchaseStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    late Color background;
    late Color foreground;
    late IconData icon;
    late String label;

    switch (status) {
      case PurchaseStatus.completed:
        background = const Color(0xFFE8F5E9);
        foreground = const Color(0xFF2E7D32);
        icon = Icons.check_circle;
        label = l10n.purchaseStatusCompleted;
      case PurchaseStatus.canceled:
        background = colorScheme.errorContainer;
        foreground = colorScheme.onErrorContainer;
        icon = Icons.cancel;
        label = l10n.purchaseStatusCanceled;
      case PurchaseStatus.packaging:
      case PurchaseStatus.delayed:
      case PurchaseStatus.shipped:
        background = const Color(0xFFFFF3E0);
        foreground = const Color(0xFFE65100);
        icon = Icons.pending;
        label = l10n.purchaseStatusPending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
