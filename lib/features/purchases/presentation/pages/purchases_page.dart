import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/core/utils/debouncer.dart';
import 'package:sales_ledger/core/utils/excel_exporter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/core/widgets/main_top_bar.dart';
import 'package:sales_ledger/core/widgets/profile_filter_dropdown.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_query.dart';
import 'package:sales_ledger/features/purchases/presentation/providers/purchase_provider.dart';
import 'package:sales_ledger/features/purchases/presentation/widgets/purchase_card.dart';

/// alımlar.html taslağına karşılık gelen alış listesi sekmesi.
class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _searchDebouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(purchasesProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final filter = ref.watch(purchaseFilterProvider);
    final purchasesAsync = ref.watch(purchasesProvider);

    ref.listen(purchasesProvider, (previous, next) {
      if (next is AsyncError) {
        CustomSnackbar.show(context, message: l10n.purchasesLoadFailed, isError: true);
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: MainTopBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.table_view_outlined),
            tooltip: l10n.commonExportExcel,
            onPressed: () async {
              final purchases = purchasesAsync.valueOrNull ?? const [];
              if (purchases.isEmpty) {
                CustomSnackbar.show(context, message: l10n.purchasesNoExportData, isError: true);
                return;
              }
              try {
                final path = await ExcelExporter.exportPurchases(purchases);
                if (context.mounted) {
                  CustomSnackbar.show(
                    context,
                    message: l10n.purchasesExportSuccess(path),
                    isError: false,
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  CustomSnackbar.show(context, message: l10n.commonExportFailed, isError: true);
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.purchasesSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => _searchDebouncer.run(
                () => ref.read(purchaseFilterProvider.notifier).setSearch(value),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ProfileFilterDropdown(
              selectedProfileId: filter.profileId,
              onChanged: (id) =>
                  ref.read(purchaseFilterProvider.notifier).setProfileFilter(id),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: l10n.commonAll,
                    selected: filter.statusFilter == PurchaseStatusFilter.all,
                    onTap: () =>
                        ref.read(purchaseFilterProvider.notifier).setStatusFilter(PurchaseStatusFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.purchasesFilterCompleted,
                    selected: filter.statusFilter == PurchaseStatusFilter.completed,
                    onTap: () => ref
                        .read(purchaseFilterProvider.notifier)
                        .setStatusFilter(PurchaseStatusFilter.completed),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.purchasesFilterPending,
                    selected: filter.statusFilter == PurchaseStatusFilter.pending,
                    onTap: () => ref
                        .read(purchaseFilterProvider.notifier)
                        .setStatusFilter(PurchaseStatusFilter.pending),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.purchasesFilterCanceled,
                    selected: filter.statusFilter == PurchaseStatusFilter.canceled,
                    onTap: () => ref
                        .read(purchaseFilterProvider.notifier)
                        .setStatusFilter(PurchaseStatusFilter.canceled),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(purchasesProvider.notifier).refresh(),
              child: purchasesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: TextButton(
                    onPressed: () => ref.read(purchasesProvider.notifier).refresh(),
                    child: Text(l10n.commonRetry),
                  ),
                ),
                data: (purchases) {
                  if (purchases.isEmpty) {
                    return Center(child: Text(l10n.purchasesEmpty));
                  }
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: purchases.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final purchase = purchases[index];
                      return PurchaseCard(
                        purchase: purchase,
                        onTap: () => context.push(AppRoutes.purchaseDetails(purchase.id)),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addPurchase),
        tooltip: l10n.purchasesAddNew,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? colorScheme.primaryContainer : colorScheme.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}
