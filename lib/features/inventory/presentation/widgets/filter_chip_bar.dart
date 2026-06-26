import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_query.dart';

/// envanter.html taslağındaki kaydırılabilir filtre çipleri + sıralama ikonu.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.stockFilter,
    required this.onStockFilterChanged,
    required this.favoritesOnly,
    required this.onFavoritesToggled,
    required this.sort,
    required this.onSortChanged,
  });

  final StockFilter stockFilter;
  final ValueChanged<StockFilter> onStockFilterChanged;
  final bool favoritesOnly;
  final VoidCallback onFavoritesToggled;
  final ProductSortOption sort;
  final ValueChanged<ProductSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: l10n.commonAll,
                  selected: stockFilter == StockFilter.all,
                  onTap: () => onStockFilterChanged(StockFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.inventoryFilterInStock,
                  selected: stockFilter == StockFilter.inStock,
                  onTap: () => onStockFilterChanged(StockFilter.inStock),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.inventoryFilterOutOfStock,
                  selected: stockFilter == StockFilter.outOfStock,
                  onTap: () => onStockFilterChanged(StockFilter.outOfStock),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.inventoryFilterFavorites,
                  selected: favoritesOnly,
                  onTap: onFavoritesToggled,
                  icon: favoritesOnly ? Icons.favorite : Icons.favorite_border,
                ),
              ],
            ),
          ),
        ),
        PopupMenuButton<ProductSortOption>(
          icon: const Icon(Icons.sort),
          tooltip: l10n.inventorySort,
          initialValue: sort,
          onSelected: onSortChanged,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ProductSortOption.alphabetical,
              child: Text(l10n.inventorySortAlphabetical),
            ),
            PopupMenuItem(
              value: ProductSortOption.priceDescending,
              child: Text(l10n.inventorySortPriceDesc),
            ),
            PopupMenuItem(
              value: ProductSortOption.priceAscending,
              child: Text(l10n.inventorySortPriceAsc),
            ),
            PopupMenuItem(
              value: ProductSortOption.bestSelling,
              child: Text(l10n.inventorySortBestSelling),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;

    return Material(
      color: selected ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? colorScheme.primaryContainer : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
