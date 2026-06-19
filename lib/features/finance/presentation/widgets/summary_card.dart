import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final bool isPrimary;
  final Color? iconColor;
  final Color? iconBgColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    this.isPrimary = false,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isPrimary) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: colorScheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(
          children: [
            // Arkaplan efekti (Görsel Zenginlik)
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, color: colorScheme.onPrimary.withOpacity(0.9))),
                    Icon(icon, color: colorScheme.onPrimary.withOpacity(0.8)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '₺${amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onPrimary, letterSpacing: -1),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconBgColor ?? colorScheme.primaryContainer, shape: BoxShape.circle),
                child: Icon(icon, size: 18, color: iconColor ?? colorScheme.primary),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Text('₺${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}