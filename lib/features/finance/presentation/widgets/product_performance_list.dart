import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/features/finance/domain/entities/product_performance.dart';

/// "En çok satan ürünler" / "En yüksek gelir getiren ürünler" listesi
/// (gereksinim 4.6).
class ProductPerformanceList extends StatelessWidget {
  const ProductPerformanceList({
    super.key,
    required this.title,
    required this.products,
    required this.valueBuilder,
  });

  final String title;
  final List<ProductPerformance> products;
  final String Function(ProductPerformance) valueBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: 12),
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(context.l10n.financeNoPeriodData, style: textTheme.bodySmall),
            )
          else
            ...List.generate(products.length, (index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text('${index + 1}.', style: textTheme.labelMedium),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product.productName,
                        style: textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      valueBuilder(product),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
