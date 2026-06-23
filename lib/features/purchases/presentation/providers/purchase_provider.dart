import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_ledger/core/network/supabase_client.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:sales_ledger/features/purchases/data/datasources/purchase_supabase_datasource.dart';
import 'package:sales_ledger/features/purchases/data/repositories/purchase_repository_impl.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item_draft.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_query.dart';
import 'package:sales_ledger/features/purchases/domain/repositories/purchase_repository.dart';
import 'package:sales_ledger/features/purchases/domain/usecases/add_purchase_usecase.dart';
import 'package:sales_ledger/features/purchases/domain/usecases/delete_purchase_usecase.dart';
import 'package:sales_ledger/features/purchases/domain/usecases/get_purchase_by_id_usecase.dart';
import 'package:sales_ledger/features/purchases/domain/usecases/get_purchase_items_usecase.dart';
import 'package:sales_ledger/features/purchases/domain/usecases/get_purchases_usecase.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepositoryImpl(
    PurchaseSupabaseDatasource(supabase),
    AuthSupabaseDatasource(supabase),
  );
});

final getPurchasesUseCaseProvider = Provider(
  (ref) => GetPurchasesUseCase(ref.watch(purchaseRepositoryProvider)),
);
final getPurchaseByIdUseCaseProvider = Provider(
  (ref) => GetPurchaseByIdUseCase(ref.watch(purchaseRepositoryProvider)),
);
final getPurchaseItemsUseCaseProvider = Provider(
  (ref) => GetPurchaseItemsUseCase(ref.watch(purchaseRepositoryProvider)),
);
final addPurchaseUseCaseProvider = Provider(
  (ref) => AddPurchaseUseCase(ref.watch(purchaseRepositoryProvider)),
);
final deletePurchaseUseCaseProvider = Provider(
  (ref) => DeletePurchaseUseCase(ref.watch(purchaseRepositoryProvider)),
);

/// Alış listesinin arama/durum filtresini tutar.
class PurchaseFilterNotifier extends Notifier<PurchaseQuery> {
  @override
  PurchaseQuery build() => const PurchaseQuery();

  void setSearch(String value) => state = state.copyWith(search: value).resetToFirstPage();

  void setStatusFilter(PurchaseStatusFilter value) =>
      state = state.copyWith(statusFilter: value).resetToFirstPage();
}

final purchaseFilterProvider = NotifierProvider<PurchaseFilterNotifier, PurchaseQuery>(
  PurchaseFilterNotifier.new,
);

/// Aktif filtreye göre sayfalandırılmış alış listesi (gereksinim 5.3).
class PurchasesNotifier extends AutoDisposeAsyncNotifier<List<Purchase>> {
  bool _hasReachedEnd = false;
  bool get hasReachedEnd => _hasReachedEnd;

  @override
  Future<List<Purchase>> build() async {
    _hasReachedEnd = false;
    final query = ref.watch(purchaseFilterProvider).resetToFirstPage();
    final purchases = await ref.read(getPurchasesUseCaseProvider)(query);
    _hasReachedEnd = purchases.length < query.pageSize;
    return purchases;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || _hasReachedEnd || state.isLoading) return;

    final nextPage = (current.length / ref.read(purchaseFilterProvider).pageSize).floor();
    final query = ref.read(purchaseFilterProvider).copyWith(page: nextPage);
    final nextPurchases = await ref.read(getPurchasesUseCaseProvider)(query);

    if (nextPurchases.length < query.pageSize) {
      _hasReachedEnd = true;
    }
    state = AsyncData([...current, ...nextPurchases]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _hasReachedEnd = false;
      final query = ref.read(purchaseFilterProvider).resetToFirstPage();
      final purchases = await ref.read(getPurchasesUseCaseProvider)(query);
      _hasReachedEnd = purchases.length < query.pageSize;
      return purchases;
    });
  }
}

final purchasesProvider = AutoDisposeAsyncNotifierProvider<PurchasesNotifier, List<Purchase>>(
  PurchasesNotifier.new,
);

final purchaseDetailsProvider =
    FutureProvider.autoDispose.family<Purchase, String>((ref, id) {
  return ref.read(getPurchaseByIdUseCaseProvider)(id);
});

final purchaseItemsProvider =
    FutureProvider.autoDispose.family<List<PurchaseItem>, String>((ref, purchaseId) {
  return ref.read(getPurchaseItemsUseCaseProvider)(purchaseId);
});

/// Alış ekleme formundaki yüklenme/hata durumunu yönetir.
class AddPurchaseController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> addPurchase({
    String? supplierName,
    required DateTime purchaseDate,
    required List<PurchaseItemDraft> items,
    String? paymentType,
    String? notes,
    List<Uint8List> photos = const [],
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(addPurchaseUseCaseProvider)(
        supplierName: supplierName,
        purchaseDate: purchaseDate,
        items: items,
        paymentType: paymentType,
        notes: notes,
        photos: photos,
      );
      state = const AsyncData(null);
      ref.invalidate(purchasesProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final addPurchaseControllerProvider = AsyncNotifierProvider<AddPurchaseController, void>(
  AddPurchaseController.new,
);
