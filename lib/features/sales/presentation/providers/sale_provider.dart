import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_ledger/core/network/supabase_client.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:sales_ledger/features/auth/presentation/providers/profile_provider.dart';
import 'package:sales_ledger/features/sales/data/datasources/sale_supabase_datasource.dart';
import 'package:sales_ledger/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:sales_ledger/features/sales/domain/entities/cargo_status.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item_draft.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_query.dart';
import 'package:sales_ledger/features/sales/domain/repositories/sale_repository.dart';
import 'package:sales_ledger/features/sales/domain/usecases/add_sale_usecase.dart';
import 'package:sales_ledger/features/sales/domain/usecases/delete_sale_usecase.dart';
import 'package:sales_ledger/features/sales/domain/usecases/get_sale_by_id_usecase.dart';
import 'package:sales_ledger/features/sales/domain/usecases/get_sale_items_usecase.dart';
import 'package:sales_ledger/features/sales/domain/usecases/get_sales_usecase.dart';
import 'package:sales_ledger/features/sales/domain/usecases/update_sale_usecase.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepositoryImpl(
    SaleSupabaseDatasource(supabase),
    AuthSupabaseDatasource(supabase),
  );
});

final getSalesUseCaseProvider = Provider(
  (ref) => GetSalesUseCase(ref.watch(saleRepositoryProvider)),
);
final getSaleByIdUseCaseProvider = Provider(
  (ref) => GetSaleByIdUseCase(ref.watch(saleRepositoryProvider)),
);
final getSaleItemsUseCaseProvider = Provider(
  (ref) => GetSaleItemsUseCase(ref.watch(saleRepositoryProvider)),
);
final addSaleUseCaseProvider = Provider(
  (ref) => AddSaleUseCase(ref.watch(saleRepositoryProvider)),
);
final deleteSaleUseCaseProvider = Provider(
  (ref) => DeleteSaleUseCase(ref.watch(saleRepositoryProvider)),
);
final updateSaleUseCaseProvider = Provider(
  (ref) => UpdateSaleUseCase(ref.watch(saleRepositoryProvider)),
);

/// Satış listesinin arama/durum/sıralama filtresini tutar.
class SaleFilterNotifier extends Notifier<SaleQuery> {
  @override
  SaleQuery build() => const SaleQuery();

  void setSearch(String value) => state = state.copyWith(search: value).resetToFirstPage();

  void setStatusFilter(CargoStatusFilter value) =>
      state = state.copyWith(statusFilter: value).resetToFirstPage();

  void setProfileFilter(String? profileId) =>
      state = state.copyWith(profileId: profileId).resetToFirstPage();

  void setSort(SaleSortOption value) => state = state.copyWith(sort: value).resetToFirstPage();
}

final saleFilterProvider = NotifierProvider<SaleFilterNotifier, SaleQuery>(
  SaleFilterNotifier.new,
);

/// Aktif filtreye göre sayfalandırılmış satış listesi (gereksinim 5.3).
class SalesNotifier extends AutoDisposeAsyncNotifier<List<Sale>> {
  bool _hasReachedEnd = false;
  bool get hasReachedEnd => _hasReachedEnd;

  @override
  Future<List<Sale>> build() async {
    _hasReachedEnd = false;
    final query = ref.watch(saleFilterProvider).resetToFirstPage();
    final sales = await ref.read(getSalesUseCaseProvider)(query);
    _hasReachedEnd = sales.length < query.pageSize;
    return sales;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || _hasReachedEnd || state.isLoading) return;

    final nextPage = (current.length / ref.read(saleFilterProvider).pageSize).floor();
    final query = ref.read(saleFilterProvider).copyWith(page: nextPage);
    final nextSales = await ref.read(getSalesUseCaseProvider)(query);

    if (nextSales.length < query.pageSize) {
      _hasReachedEnd = true;
    }
    state = AsyncData([...current, ...nextSales]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _hasReachedEnd = false;
      final query = ref.read(saleFilterProvider).resetToFirstPage();
      final sales = await ref.read(getSalesUseCaseProvider)(query);
      _hasReachedEnd = sales.length < query.pageSize;
      return sales;
    });
  }
}

final salesProvider = AutoDisposeAsyncNotifierProvider<SalesNotifier, List<Sale>>(
  SalesNotifier.new,
);

final saleDetailsProvider = FutureProvider.autoDispose.family<Sale, String>((ref, id) {
  return ref.read(getSaleByIdUseCaseProvider)(id);
});

final saleItemsProvider =
    FutureProvider.autoDispose.family<List<SaleItem>, String>((ref, saleId) {
  return ref.read(getSaleItemsUseCaseProvider)(saleId);
});

/// Satış ekleme formundaki yüklenme/hata durumunu yönetir.
class AddSaleController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> addSale({
    String? customerName,
    required DateTime saleDate,
    String? platform,
    required List<SaleItemDraft> items,
    CargoStatus status = CargoStatus.packaging,
    String? trackingNumber,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(addSaleUseCaseProvider)(
        customerName: customerName,
        saleDate: saleDate,
        platform: platform,
        items: items,
        status: status,
        trackingNumber: trackingNumber,
        notes: notes,
        profileId: ref.read(selectedProfileProvider)?.id,
      );
      state = const AsyncData(null);
      ref.invalidate(salesProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateSale({
    required String saleId,
    String? customerName,
    required DateTime saleDate,
    String? platform,
    required List<SaleItemDraft> items,
    CargoStatus status = CargoStatus.packaging,
    String? trackingNumber,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(updateSaleUseCaseProvider)(
        saleId: saleId,
        customerName: customerName,
        saleDate: saleDate,
        platform: platform,
        items: items,
        status: status,
        trackingNumber: trackingNumber,
        notes: notes,
      );
      state = const AsyncData(null);
      ref.invalidate(salesProvider);
      ref.invalidate(saleDetailsProvider(saleId));
      ref.invalidate(saleItemsProvider(saleId));
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final addSaleControllerProvider = AsyncNotifierProvider<AddSaleController, void>(
  AddSaleController.new,
);
