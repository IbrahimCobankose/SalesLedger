import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/core/utils/debouncer.dart';
import 'package:sales_ledger/core/utils/excel_exporter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/core/widgets/main_top_bar.dart';
import 'package:sales_ledger/features/inventory/presentation/providers/product_provider.dart';
import 'package:sales_ledger/features/inventory/presentation/widgets/filter_chip_bar.dart';
import 'package:sales_ledger/features/inventory/presentation/widgets/product_card.dart';

/// envanter.html taslağına karşılık gelen envanter (ürün listesi) sekmesi.
class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
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
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final filter = ref.watch(productFilterProvider);
    final productsAsync = ref.watch(productsProvider);

    ref.listen(productsProvider, (previous, next) {
      if (next is AsyncError) {
        CustomSnackbar.show(context, message: l10n.inventoryLoadFailed, isError: true);
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: MainTopBar(
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) {
                _searchController.clear();
                ref.read(productFilterProvider.notifier).setSearch('');
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.table_view_outlined),
            tooltip: l10n.commonExportExcel,
            onPressed: () async {
              final products = productsAsync.valueOrNull ?? const [];
              if (products.isEmpty) {
                CustomSnackbar.show(context, message: l10n.inventoryNoExportData, isError: true);
                return;
              }
              try {
                final path = await ExcelExporter.exportProducts(products);
                if (context.mounted) {
                  CustomSnackbar.show(
                    context,
                    message: l10n.inventoryExportSuccess(path),
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
                  hintText: l10n.inventorySearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => _searchDebouncer.run(
                  () => ref.read(productFilterProvider.notifier).setSearch(value),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilterChipBar(
              stockFilter: filter.stockFilter,
              onStockFilterChanged: (value) =>
                  ref.read(productFilterProvider.notifier).setStockFilter(value),
              sort: filter.sort,
              onSortChanged: (value) => ref.read(productFilterProvider.notifier).setSort(value),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(productsProvider.notifier).refresh(),
              child: productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: TextButton(
                    onPressed: () => ref.read(productsProvider.notifier).refresh(),
                    child: Text(l10n.commonRetry),
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return Center(child: Text(l10n.inventoryEmpty));
                  }
                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 480,
                      mainAxisExtent: 104,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push(AppRoutes.productDetails(product.id)),
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
        onPressed: () => context.push(AppRoutes.addProduct),
        tooltip: l10n.inventoryAddNew,
        child: const Icon(Icons.add),
      ),
    );
  }
}
