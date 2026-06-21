import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/confirm_dialog.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item.dart';
import 'package:sales_ledger/features/purchases/presentation/providers/purchase_provider.dart';
import 'package:sales_ledger/features/purchases/presentation/widgets/purchase_card.dart' show formatTurkishDate;
import 'package:sales_ledger/features/purchases/presentation/widgets/purchase_status_badge.dart';

/// alış_detay.html taslağına karşılık gelen alış detay sayfası.
class PurchaseDetailsPage extends ConsumerWidget {
  const PurchaseDetailsPage({super.key, required this.purchaseId});

  final String purchaseId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.purchaseDetailsDeleteTitle,
      message: l10n.purchaseDetailsDeleteMessage,
    );
    if (!confirmed) return;

    try {
      await ref.read(deletePurchaseUseCaseProvider)(purchaseId);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: e is AppException ? e.message : l10n.purchaseDetailsDeleteFailed,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final purchaseAsync = ref.watch(purchaseDetailsProvider(purchaseId));
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.purchaseDetailsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: purchaseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.purchaseDetailsLoadFailed)),
        data: (purchase) => _PurchaseDetailsBody(purchase: purchase),
      ),
    );
  }
}

class _PurchaseDetailsBody extends ConsumerWidget {
  const _PurchaseDetailsBody({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final itemsAsync = ref.watch(purchaseItemsProvider(purchase.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flex(
              direction: MediaQuery.of(context).size.width > 700 ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.purchaseDetailsSupplierInfo,
                              style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                            PurchaseStatusBadge(status: purchase.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(purchase.displaySupplierName, style: textTheme.headlineMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16, height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.purchaseDetailsTotalAmount,
                          style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₺${purchase.totalAmount.toStringAsFixed(2)}',
                          style: textTheme.displayLarge?.copyWith(color: colorScheme.primary),
                        ),
                        const SizedBox(height: 16),
                        _SummaryRow(label: l10n.commonDate, value: formatTurkishDate(purchase.purchaseDate)),
                        if (purchase.paymentType != null)
                          _SummaryRow(label: l10n.purchaseDetailsPaymentType, value: purchase.paymentType!),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.purchaseDetailsItemsTitle, style: textTheme.titleLarge),
                  ),
                  itemsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.purchaseDetailsItemsFailed),
                    ),
                    data: (items) => _ItemsTable(items: items),
                  ),
                ],
              ),
            ),
            if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.purchaseDetailsNotes,
                      style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(purchase.notes!, style: textTheme.bodyMedium),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ItemsTable extends StatelessWidget {
  const _ItemsTable({required this.items});

  final List<PurchaseItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.purchaseDetailsNoItems),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
        columns: [
          DataColumn(label: Text(l10n.purchaseDetailsColumnProductName)),
          DataColumn(label: Text(l10n.commonQuantity), numeric: true),
          DataColumn(label: Text(l10n.purchaseDetailsColumnUnitPrice), numeric: true),
          DataColumn(label: Text(l10n.purchaseDetailsColumnTotal), numeric: true),
        ],
        rows: items
            .map(
              (item) => DataRow(
                cells: [
                  DataCell(Text(item.name, style: textTheme.bodyMedium)),
                  DataCell(Text('${item.quantity}')),
                  DataCell(Text('₺${item.customPurchasePrice.toStringAsFixed(2)}')),
                  DataCell(Text(
                    '₺${item.lineTotal.toStringAsFixed(2)}',
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  )),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
