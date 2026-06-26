import 'package:flutter/material.dart';
import 'package:sales_ledger/features/finance/domain/entities/cash_movement.dart';

const _months = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

String _formatDateTime(DateTime date) {
  final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  return '${date.day} ${_months[date.month - 1]}, $time';
}

/// kasa_hareketleri.html taslağındaki gelir/gider satırı. Gelir → yeşil
/// arrow_downward, gider → kırmızı arrow_upward (gereksinim 4.5.2).
class CashMovementTile extends StatelessWidget {
  const CashMovementTile({super.key, required this.movement, this.onTap});

  final CashMovement movement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = movement.type == CashMovementType.income;
    final iconBackground = isIncome ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final iconColor = isIncome ? const Color(0xFF166534) : const Color(0xFF991B1B);
    final amountColor = isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final sign = isIncome ? '+' : '-';

    final content = Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(_formatDateTime(movement.date), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '$sign ₺${movement.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: amountColor),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
