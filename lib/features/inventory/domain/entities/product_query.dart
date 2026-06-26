import 'package:sales_ledger/core/constants/app_limits.dart';

/// Envanter listesi sıralama seçenekleri (gereksinim 4.2.1).
enum ProductSortOption {
  priceDescending,
  priceAscending,
  bestSelling,
  alphabetical,
}

/// Stok durumuna göre filtreleme seçenekleri.
enum StockFilter { all, inStock, outOfStock }

/// Envanter listesi sorgu parametreleri: arama, kategori, stok filtresi,
/// sıralama ve sayfalama (gereksinim 5.3 — sayfalandırılmış listeler).
class ProductQuery {
  const ProductQuery({
    this.search = '',
    this.category,
    this.stockFilter = StockFilter.all,
    this.favoritesOnly = false,
    this.sort = ProductSortOption.alphabetical,
    this.page = 0,
    this.pageSize = AppLimits.defaultPageSize,
  });

  final String search;
  final String? category;
  final StockFilter stockFilter;

  /// Yalnızca favori işaretli ürünleri göster (stok filtresinden bağımsız).
  final bool favoritesOnly;
  final ProductSortOption sort;
  final int page;
  final int pageSize;

  ProductQuery copyWith({
    String? search,
    String? category,
    StockFilter? stockFilter,
    bool? favoritesOnly,
    ProductSortOption? sort,
    int? page,
  }) {
    return ProductQuery(
      search: search ?? this.search,
      category: category ?? this.category,
      stockFilter: stockFilter ?? this.stockFilter,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      pageSize: pageSize,
    );
  }

  /// Filtre değiştiğinde (arama/kategori/stok/sıralama hariç sayfa) ilk
  /// sayfaya dönmek için kullanılır.
  ProductQuery resetToFirstPage() => copyWith(page: 0);
}
