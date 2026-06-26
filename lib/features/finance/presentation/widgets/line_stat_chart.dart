import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/features/finance/domain/entities/chart_point.dart';

/// Gelir/Gider çizgi grafiği — [StatChart] (çubuk) ile aynı veriyi çizgi
/// olarak gösteren alternatif. Genişliğe sığacak şekilde çizildiğinden taşma
/// (overflow) olmaz.
class LineStatChart extends StatelessWidget {
  const LineStatChart({super.key, required this.points});

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, 192),
                painter: _LinePainter(
                  points: points,
                  safeMax: safeMax,
                  incomeColor: colorScheme.primary,
                  expenseColor: colorScheme.error,
                  gridColor: colorScheme.outlineVariant,
                  labelStyle: (textTheme.labelSmall ?? const TextStyle(fontSize: 11))
                      .copyWith(color: colorScheme.onSurfaceVariant),
                ),
              );
            },
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

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.points,
    required this.safeMax,
    required this.incomeColor,
    required this.expenseColor,
    required this.gridColor,
    required this.labelStyle,
  });

  final List<ChartPoint> points;
  final double safeMax;
  final Color incomeColor;
  final Color expenseColor;
  final Color gridColor;
  final TextStyle labelStyle;

  static const double _labelHeight = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - _labelHeight;
    final slotWidth = size.width / points.length;

    // Hafif yatay kılavuz çizgisi (taban).
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, chartHeight), Offset(size.width, chartHeight), gridPaint);

    double xFor(int i) => slotWidth * (i + 0.5);
    double yFor(double value) => chartHeight - (value / safeMax).clamp(0, 1) * chartHeight;

    void drawSeries(double Function(ChartPoint) selector, Color color) {
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      final dotPaint = Paint()..color = color;

      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final offset = Offset(xFor(i), yFor(selector(points[i])));
        if (i == 0) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
      canvas.drawPath(path, linePaint);
      for (var i = 0; i < points.length; i++) {
        canvas.drawCircle(Offset(xFor(i), yFor(selector(points[i]))), 3, dotPaint);
      }
    }

    drawSeries((p) => p.expense, expenseColor);
    drawSeries((p) => p.income, incomeColor);

    // X ekseni etiketleri.
    for (var i = 0; i < points.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: points[i].label, style: labelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: slotWidth);
      tp.paint(
        canvas,
        Offset(xFor(i) - tp.width / 2, chartHeight + (_labelHeight - tp.height) / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.safeMax != safeMax ||
        oldDelegate.incomeColor != incomeColor ||
        oldDelegate.expenseColor != expenseColor;
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
