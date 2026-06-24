import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_ledger/core/network/supabase_client.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:sales_ledger/features/inventory/data/datasources/product_supabase_datasource.dart';
import 'package:sales_ledger/features/inventory/data/repositories/product_repository_impl.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_query.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_sale_history_item.dart';
import 'package:sales_ledger/features/inventory/domain/repositories/product_repository.dart';
import 'package:sales_ledger/features/inventory/domain/usecases/add_product_usecase.dart';
import 'package:sales_ledger/features/inventory/domain/usecases/delete_product_usecase.dart';
import 'package:sales_ledger/features/inventory/domain/usecases/get_product_by_id_usecase.dart';
import 'package:sales_ledger/features/inventory/domain/usecases/get_product_sale_history_usecase.dart';
import 'package:sales_ledger/features/inventory/domain/usecases/get_products_usecase.dart';
import 'package:sales_ledger/features/inventory/domain/usecases/update_product_usecase.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    ProductSupabaseDatasource(supabase),
    AuthSupabaseDatasource(supabase),
  );
});

final getProductsUseCaseProvider = Provider(
  (ref) => GetProductsUseCase(ref.watch(productRepositoryProvider)),
);
final getProductByIdUseCaseProvider = Provider(
  (ref) => GetProductByIdUseCase(ref.watch(productRepositoryProvider)),
);
final addProductUseCaseProvider = Provider(
  (ref) => AddProductUseCase(ref.watch(productRepositoryProvider)),
);
final updateProductUseCaseProvider = Provider(
  (ref) => UpdateProductUseCase(ref.watch(productRepositoryProvider)),
);
final deleteProductUseCaseProvider = Provider(
  (ref) => DeleteProductUseCase(ref.watch(productRepositoryProvider)),
);
final getProductSaleHistoryUseCaseProvider = Provider(
  (ref) => GetProductSaleHistoryUseCase(ref.watch(productRepositoryProvider)),
);

/// Envanter listesinin arama/kategori/stok/sıralama filtrelerini tutar.
/// Değiştiğinde [productsProvider] otomatik olarak yeniden sorgulanır.
class ProductFilterNotifier extends Notifier<ProductQuery> {
  @override
  ProductQuery build() => const ProductQuery();

  void setSearch(String value) => state = state.copyWith(search: value).resetToFirstPage();

  void setCategory(String? value) => state = state.copyWith(category: value).resetToFirstPage();

  void setStockFilter(StockFilter value) =>
      state = state.copyWith(stockFilter: value).resetToFirstPage();

  void setSort(ProductSortOption value) => state = state.copyWith(sort: value).resetToFirstPage();
}

final productFilterProvider = NotifierProvider<ProductFilterNotifier, ProductQuery>(
  ProductFilterNotifier.new,
);

/// Aktif filtreye göre sayfalandırılmış ürün listesi (gereksinim 5.3).
/// [loadMore], mevcut listeye bir sonraki sayfayı ekler (sonsuz kaydırma).
class ProductsNotifier extends AutoDisposeAsyncNotifier<List<Product>> {
  bool _hasReachedEnd = false;
  bool get hasReachedEnd => _hasReachedEnd;

  @override
  Future<List<Product>> build() async {
    _hasReachedEnd = false;
    final query = ref.watch(productFilterProvider).resetToFirstPage();
    final products = await ref.read(getProductsUseCaseProvider)(query);
    _hasReachedEnd = products.length < query.pageSize;
    return products;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || _hasReachedEnd || state.isLoading) return;

    final nextPage = (current.length / ref.read(productFilterProvider).pageSize).floor();
    final query = ref.read(productFilterProvider).copyWith(page: nextPage);
    final nextProducts = await ref.read(getProductsUseCaseProvider)(query);

    if (nextProducts.length < query.pageSize) {
      _hasReachedEnd = true;
    }
    state = AsyncData([...current, ...nextProducts]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _hasReachedEnd = false;
      final query = ref.read(productFilterProvider).resetToFirstPage();
      final products = await ref.read(getProductsUseCaseProvider)(query);
      _hasReachedEnd = products.length < query.pageSize;
      return products;
    });
  }
}

final productsProvider = AutoDisposeAsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

final productDetailsProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) {
  return ref.read(getProductByIdUseCaseProvider)(id);
});

final productSaleHistoryProvider =
    FutureProvider.autoDispose.family<List<ProductSaleHistoryItem>, String>((ref, productId) {
  return ref.read(getProductSaleHistoryUseCaseProvider)(productId);
});

/// Ürün ekleme formundaki yüklenme/hata durumunu yönetir.
class AddProductController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> addProduct({
    required String name,
    required double salePrice,
    required List<Uint8List> photos,
    double? productionCost,
    String? category,
    int initialStock = 0,
    double? length,
    double? width,
    double? height,
    double? weight,
    String? description,
    String? notes,
    List<String> tags = const [],
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(addProductUseCaseProvider)(
        name: name,
        salePrice: salePrice,
        photos: photos,
        productionCost: productionCost,
        category: category,
        initialStock: initialStock,
        length: length,
        width: width,
        height: height,
        weight: weight,
        description: description,
        notes: notes,
        tags: tags,
      );
      state = const AsyncData(null);
      ref.invalidate(productsProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Mevcut ürünü günceller. [original] düzenlenen ürünün son halidir;
  /// [keptPhotoUrls] formda korunan mevcut fotoğraflar, [newPhotos] yeni
  /// eklenenlerdir. Opsiyonel alanlara `null` verilirse alan temizlenir.
  Future<bool> updateProduct({
    required Product original,
    required String name,
    required double salePrice,
    required List<String> keptPhotoUrls,
    List<Uint8List> newPhotos = const [],
    double? productionCost,
    String? category,
    int? stockQuantity,
    double? length,
    double? width,
    double? height,
    double? weight,
    String? description,
    String? notes,
    List<String> tags = const [],
  }) async {
    state = const AsyncLoading();
    try {
      final updated = Product(
        id: original.id,
        userId: original.userId,
        name: name,
        salePrice: salePrice,
        productionCost: productionCost,
        length: length,
        width: width,
        height: height,
        weight: weight,
        description: description,
        stockQuantity: stockQuantity ?? original.stockQuantity,
        soldCount: original.soldCount,
        notes: notes,
        photos: keptPhotoUrls,
        category: category,
        tags: tags,
        createdAt: original.createdAt,
      );
      await ref.read(updateProductUseCaseProvider)(updated, newPhotos: newPhotos);
      state = const AsyncData(null);
      ref.invalidate(productsProvider);
      ref.invalidate(productDetailsProvider(original.id));
      ref.invalidate(productSaleHistoryProvider(original.id));
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final addProductControllerProvider = AsyncNotifierProvider<AddProductController, void>(
  AddProductController.new,
);
