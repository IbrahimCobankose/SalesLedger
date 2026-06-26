import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/gen/app_localizations.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/core/utils/debouncer.dart';
import 'package:sales_ledger/core/utils/excel_exporter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/core/widgets/main_top_bar.dart';
import 'package:sales_ledger/core/widgets/profile_filter_dropdown.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_query.dart';
import 'package:sales_ledger/features/sales/presentation/providers/sale_provider.dart';
import 'package:sales_ledger/features/sales/presentation/widgets/sale_card.dart';

/// [CargoStatusFilter] etiketleri, domain'deki Türkçe `.label` yerine
/// burada yerelleştirilir.
String _cargoStatusFilterLabel(AppLocalizations l10n, CargoStatusFilter filter) {
  switch (filter) {
    case CargoStatusFilter.all:
      return l10n.commonAll;
    case CargoStatusFilter.packaging:
      return l10n.cargoStatusPackaging;
    case CargoStatusFilter.delayed:
      return l10n.cargoStatusDelayed;
    case CargoStatusFilter.shipped:
      return l10n.cargoStatusShipped;
    case CargoStatusFilter.completed:
      return l10n.cargoStatusCompleted;
    case CargoStatusFilter.canceled:
      return l10n.cargoStatusCanceled;
  }
}

/// satışlar.html taslağına karşılık gelen satış listesi sekmesi.
class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _searchDebouncer = Debouncer();
  bool _searching = false;

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
      ref.read(salesProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final filter = ref.watch(saleFilterProvider);
    final salesAsync = ref.watch(salesProvider);

    ref.listen(salesProvider, (previous, next) {
      if (next is AsyncError) {
        CustomSnackbar.show(context, message: l10n.salesLoadFailed, isError: true);
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: MainTopBar(
        title: l10n.salesTitle,
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) {
                _searchController.clear();
                ref.read(saleFilterProvider.notifier).setSearch('');
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.table_view_outlined),
            tooltip: l10n.commonExportExcel,
            onPressed: () async {
              final sales = salesAsync.valueOrNull ?? const [];
              if (sales.isEmpty) {
                CustomSnackbar.show(context, message: l10n.salesNoExportData, isError: true);
                return;
              }
              try {
                final path = await ExcelExporter.exportSales(sales);
                if (context.mounted) {
                  CustomSnackbar.show(
                    context,
                    message: l10n.salesExportSuccess(path),
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
          if (_searching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.salesSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => _searchDebouncer.run(
                  () => ref.read(saleFilterProvider.notifier).setSearch(value),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ProfileFilterDropdown(
              selectedProfileId: filter.profileId,
              onChanged: (id) =>
                  ref.read(saleFilterProvider.notifier).setProfileFilter(id),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final option in CargoStatusFilter.values) ...[
                          _FilterChip(
                            label: _cargoStatusFilterLabel(l10n, option),
                            selected: filter.statusFilter == option,
                            onTap: () => ref.read(saleFilterProvider.notifier).setStatusFilter(option),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<SaleSortOption>(
                  icon: const Icon(Icons.sort),
                  tooltip: l10n.inventorySort,
                  initialValue: filter.sort,
                  onSelected: (value) => ref.read(saleFilterProvider.notifier).setSort(value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: SaleSortOption.dateDescending,
                      child: Text(l10n.salesSortNewestFirst),
                    ),
                    PopupMenuItem(
                      value: SaleSortOption.dateAscending,
                      child: Text(l10n.salesSortOldestFirst),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(salesProvider.notifier).refresh(),
              child: salesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: TextButton(
                    onPressed: () => ref.read(salesProvider.notifier).refresh(),
                    child: Text(l10n.commonRetry),
                  ),
                ),
                data: (sales) {
                  if (sales.isEmpty) {
                    return Center(child: Text(l10n.salesEmpty));
                  }
                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 420,
                      mainAxisExtent: 176,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return SaleCard(
                        sale: sale,
                        onTap: () => context.push(AppRoutes.saleDetails(sale.id)),
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
        onPressed: () => context.push(AppRoutes.addSale),
        tooltip: l10n.salesAddNew,
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
      color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainer,
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
