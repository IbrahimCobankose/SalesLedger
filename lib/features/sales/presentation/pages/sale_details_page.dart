import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/confirm_dialog.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item.dart';
import 'package:sales_ledger/features/sales/presentation/providers/sale_provider.dart';
import 'package:sales_ledger/features/sales/presentation/widgets/cargo_status_badge.dart';
import 'package:sales_ledger/features/sales/presentation/widgets/sale_card.dart' show formatTurkishDate;

/// satış_detay.html taslağına karşılık gelen satış detay sayfası.
class SaleDetailsPage extends ConsumerWidget {
  const SaleDetailsPage({super.key, required this.saleId});

  final String saleId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.saleDetailsDeleteTitle,
      message: l10n.saleDetailsDeleteMessage,
    );
    if (!confirmed) return;

    try {
      await ref.read(deleteSaleUseCaseProvider)(saleId);
      ref.invalidate(salesProvider);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: e is AppException ? e.message : l10n.saleDetailsDeleteFailed,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final saleAsync = ref.watch(saleDetailsProvider(saleId));
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.saleDetailsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Düzenle',
            onPressed: () => context.push(AppRoutes.saleEdit(saleId)),
          ),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref)),
        ],
      ),
      body: saleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.saleDetailsLoadFailed)),
        data: (sale) => _SaleDetailsBody(sale: sale),
      ),
    );
  }
}

class _SaleDetailsBody extends ConsumerWidget {
  const _SaleDetailsBody({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final itemsAsync = ref.watch(saleItemsProvider(sale.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.surfaceContainerHighest),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.saleDetailsCustomer,
                              style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                            Text(sale.displayCustomerName, style: textTheme.headlineSmall),
                            if (sale.platform != null && sale.platform!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.storefront, size: 16, color: colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(sale.platform!, style: textTheme.bodySmall),
                                ],
                              ),
                            ],
                            if (sale.profileName != null && sale.profileName!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.person_outline, size: 16, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      sale.profileName!,
                                      style: textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.saleDetailsAmount,
                            style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          Text(
                            '₺${sale.totalAmount.toStringAsFixed(2)}',
                            style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(formatTurkishDate(sale.saleDate), style: textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.saleDetailsStatus, style: textTheme.labelSmall),
                            const SizedBox(height: 4),
                            CargoStatusBadge(status: sale.status),
                          ],
                        ),
                      ),
                      if (sale.trackingNumber != null && sale.trackingNumber!.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.saleDetailsTrackingNumber, style: textTheme.labelSmall),
                              const SizedBox(height: 4),
                              Text(sale.trackingNumber!, style: textTheme.bodySmall),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.saleDetailsItemsTitle, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            itemsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text(l10n.saleDetailsItemsFailed),
              data: (items) {
                if (items.isEmpty) {
                  return Text(l10n.saleDetailsNoItems);
                }
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.surfaceContainerHighest),
                  ),
                  child: Column(
                    children: items.map((item) => _SaleItemTile(item: item)).toList(),
                  ),
                );
              },
            ),
            if (sale.notes != null && sale.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.commonNotes, style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(sale.notes!, style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SaleItemTile extends StatelessWidget {
  const _SaleItemTile({required this.item});

  final SaleItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.surfaceContainerHighest)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.inventory_2_outlined, color: colorScheme.outline),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  context.l10n.saleDetailsQuantityLine(item.quantity),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '₺${item.lineTotal.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
