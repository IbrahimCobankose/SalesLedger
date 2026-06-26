import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/storage/storage_buckets.dart';
import 'package:sales_ledger/core/storage/storage_image.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/confirm_dialog.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_sale_history_item.dart';
import 'package:sales_ledger/features/inventory/presentation/providers/product_provider.dart';

/// ürün_detaylar.html taslağına karşılık gelen ürün detay sayfası.
class ProductDetailsPage extends ConsumerWidget {
  const ProductDetailsPage({super.key, required this.productId});

  final String productId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.productDetailsDeleteTitle,
      message: l10n.productDetailsDeleteMessage,
    );
    if (!confirmed) return;

    try {
      await ref.read(deleteProductUseCaseProvider)(productId);
      ref.invalidate(productsProvider);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: e is AppException ? e.message : l10n.productDetailsDeleteFailed,
          isError: true,
        );
      }
    }
  }

  Future<void> _toggleFavorite(WidgetRef ref, Product product) async {
    await ref
        .read(productRepositoryProvider)
        .setFavorite(product.id, !product.isFavorite);
    ref.invalidate(productDetailsProvider(productId));
    ref.invalidate(productsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final productAsync = ref.watch(productDetailsProvider(productId));
    final product = productAsync.valueOrNull;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.productDetailsTitle),
        centerTitle: true,
        actions: [
          if (product != null)
            IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: product.isFavorite ? colorScheme.error : null,
              ),
              tooltip: product.isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
              onPressed: () => _toggleFavorite(ref, product),
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Düzenle',
            onPressed: () => context.push(AppRoutes.productEdit(productId)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.productDetailsLoadFailed)),
        data: (product) => _ProductDetailsBody(product: product),
      ),
    );
  }
}

class _ProductDetailsBody extends ConsumerWidget {
  const _ProductDetailsBody({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final historyAsync = ref.watch(productSaleHistoryProvider(product.id));
    final isWide = MediaQuery.of(context).size.width > 700;

    final image = Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 1,
        child: product.photos.isNotEmpty
            ? StorageImage(
                bucket: StorageBuckets.productPhotos,
                path: product.photos.first,
                fit: BoxFit.cover,
              )
            : Icon(Icons.inventory_2_outlined, size: 48, color: colorScheme.outline),
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(product.name, style: textTheme.displayLarge),
        const SizedBox(height: 4),
        Text(
          '₺${product.salePrice.toStringAsFixed(2)}',
          style: textTheme.displayLarge?.copyWith(color: colorScheme.primary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: l10n.productDetailsStockStatus,
                icon: Icons.inventory_2,
                value: l10n.commonUnitsCount(product.stockQuantity),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                label: l10n.productDetailsTotalSales,
                icon: Icons.trending_up,
                value: l10n.commonUnitsCount(product.soldCount),
              ),
            ),
          ],
        ),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Geniş ekranda yan yana (Row), dar ekranda alt alta (Column).
            // Dar ekranda Expanded KULLANILMAZ; aksi halde dikey kaydırma
            // içinde sınırsız yükseklik hatası oluşur ve sayfa boş kalır.
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 320, child: image),
                  const SizedBox(width: 24),
                  Expanded(child: info),
                ],
              )
            else ...[
              image,
              const SizedBox(height: 24),
              info,
            ],
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
              childAspectRatio: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                if (product.productionCost != null)
                  _DetailCard(
                    label: l10n.productDetailsCost,
                    value: '₺${product.productionCost!.toStringAsFixed(2)}',
                  ),
                if (product.profitMarginPercent != null)
                  _DetailCard(
                    label: l10n.productDetailsMargin,
                    value: '%${product.profitMarginPercent!.toStringAsFixed(1)}',
                    highlight: true,
                  ),
                if (product.length != null || product.width != null || product.height != null)
                  _DetailCard(
                    label: l10n.productDetailsDimensions,
                    value:
                        '${product.length ?? '-'} x ${product.width ?? '-'} x ${product.height ?? '-'} cm',
                  ),
                if (product.weight != null)
                  _DetailCard(label: l10n.productDetailsWeight, value: '${product.weight} kg'),
              ],
            ),
            const SizedBox(height: 16),
            if (product.description != null && product.description!.isNotEmpty)
              _TextSection(title: l10n.productDetailsDescription, text: product.description!),
            if (product.notes != null && product.notes!.isNotEmpty)
              _TextSection(
                title: l10n.productDetailsInternalNotes,
                text: product.notes!,
                icon: Icons.note_outlined,
                italic: true,
              ),
            const SizedBox(height: 16),
            Text(l10n.productDetailsRecentSales, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            historyAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text(l10n.productDetailsSalesHistoryFailed),
              data: (history) {
                if (history.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(l10n.productDetailsNoSalesHistory),
                  );
                }
                return Column(
                  children: history.map((item) => _SaleHistoryTile(item: item)).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.icon, required this.value});

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 4),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: highlight ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.title, required this.text, this.icon, this.italic = false});

  final String title;
  final String text;
  final IconData? icon;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 4)],
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                ),
          ),
        ],
      ),
    );
  }
}

class _SaleHistoryTile extends StatelessWidget {
  const _SaleHistoryTile({required this.item});

  final ProductSaleHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateLabel = _formatTurkishDate(item.saleDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.receipt_long, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.productDetailsSaleHistoryLine(dateLabel, item.quantity),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          Text('₺${item.lineTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

const _turkishMonths = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

String _formatTurkishDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} ${_turkishMonths[date.month - 1]} ${date.year}';
}
