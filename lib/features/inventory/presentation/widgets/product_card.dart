import 'package:flutter/material.dart';
import 'package:sales_ledger/core/storage/storage_buckets.dart';
import 'package:sales_ledger/core/storage/storage_image.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/inventory/presentation/widgets/stock_badge.dart';

/// envanter.html "bento grid" ürün kartı. Stokta yoksa kart soluklaşır ve
/// görsel gri tonlamaya çevrilir.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onToggleFavorite,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final outOfStock = !product.isInStock;

    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: outOfStock ? colorScheme.errorContainer : colorScheme.surfaceContainerHigh,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _maybeGrayscale(
              outOfStock,
              SizedBox(
                width: 80,
                height: 80,
                child: product.photos.isNotEmpty
                    ? StorageImage(
                        bucket: StorageBuckets.productPhotos,
                        path: product.photos.first,
                        fit: BoxFit.cover,
                        placeholder: Container(color: colorScheme.surfaceContainer),
                        errorWidget: Container(
                          color: colorScheme.surfaceContainer,
                          child: Icon(Icons.image_not_supported_outlined, color: colorScheme.outline),
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceContainer,
                        child: Icon(Icons.inventory_2_outlined, color: colorScheme.outline),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '₺${product.salePrice.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineSmall?.copyWith(
                          color: outOfStock ? colorScheme.onSurfaceVariant : colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StockBadge(stockQuantity: product.stockQuantity),
                  ],
                ),
                if (product.category != null && product.category!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.category!,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (product.profileName != null && product.profileName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 12, color: colorScheme.outline),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.profileName!,
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
          if (onToggleFavorite != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: product.isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: product.isFavorite ? colorScheme.error : colorScheme.outline,
              ),
              onPressed: onToggleFavorite,
            ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(opacity: outOfStock ? 0.75 : 1, child: card),
      ),
    );
  }

  Widget _maybeGrayscale(bool enabled, Widget child) {
    if (!enabled) return child;
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: child,
    );
  }
}
