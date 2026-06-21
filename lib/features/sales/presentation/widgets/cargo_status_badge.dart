import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/features/sales/domain/entities/cargo_status.dart';

/// Kargo durum rozeti — tüm 5 durum için gereksinim 4.3.2'deki renk
/// kodlarını birebir uygular (test edilebilirlik için ayrı widget,
/// gereksinim 8.2).
class CargoStatusBadge extends StatelessWidget {
  const CargoStatusBadge({super.key, required this.status});

  final CargoStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    late Color background;
    late Color foreground;
    late IconData icon;
    late String label;

    switch (status) {
      case CargoStatus.packaging:
        background = const Color(0xFFE8F5E9);
        foreground = const Color(0xFF2E7D32);
        icon = Icons.inventory_2;
        label = l10n.cargoStatusPackaging;
      case CargoStatus.delayed:
        background = const Color(0xFFFFDCC6); // tertiary-fixed
        foreground = const Color(0xFF723600); // on-tertiary-fixed-variant
        icon = Icons.local_shipping;
        label = l10n.cargoStatusDelayed;
      case CargoStatus.shipped:
        background = const Color(0xFFD2E4FF); // primary-fixed
        foreground = const Color(0xFF001C37); // on-primary-fixed
        icon = Icons.local_shipping;
        label = l10n.cargoStatusShipped;
      case CargoStatus.completed:
        background = const Color(0xFFE6F4EA);
        foreground = const Color(0xFF137333);
        icon = Icons.check_circle;
        label = l10n.cargoStatusCompleted;
      case CargoStatus.canceled:
        background = const Color(0xFFFFDAD6); // error-container
        foreground = const Color(0xFF93000A); // on-error-container
        icon = Icons.cancel;
        label = l10n.cargoStatusCanceled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
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
