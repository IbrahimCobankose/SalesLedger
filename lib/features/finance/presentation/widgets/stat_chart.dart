import 'package:flutter/material.dart';

class StatChart extends StatelessWidget {
  const StatChart({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gelir / Gider Analizi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              Icon(Icons.more_vert, color: colorScheme.primary),
            ],
          ),
          const SizedBox(height: 24),
          // Grafik Alanı (Mockup)
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBarPair(context, 0.6, 0.4, 'H1'),
                _buildBarPair(context, 0.85, 0.3, 'H2'),
                _buildBarPair(context, 0.5, 0.65, 'H3'),
                _buildBarPair(context, 0.95, 0.45, 'H4'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Lejant
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(colorScheme.primary, 'Gelir', colorScheme),
              const SizedBox(width: 16),
              _buildLegend(colorScheme.error, 'Gider', colorScheme),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBarPair(BuildContext context, double incomeFactor, double expenseFactor, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(width: 12, decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(4)), child: FractionallySizedBox(heightFactor: incomeFactor, alignment: Alignment.bottomCenter, child: Container(color: colorScheme.primary))),
              const SizedBox(width: 4),
              Container(width: 12, decoration: BoxDecoration(color: colorScheme.error, borderRadius: BorderRadius.circular(4)), child: FractionallySizedBox(heightFactor: expenseFactor, alignment: Alignment.bottomCenter, child: Container(color: colorScheme.error))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildLegend(Color color, String label, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}