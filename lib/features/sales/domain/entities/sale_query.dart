import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/features/sales/domain/entities/cargo_status.dart';

/// Liste filtreleme seçenekleri (satışlar.html "Durum: Tümü" filtresi).
enum CargoStatusFilter { all, packaging, delayed, shipped, completed, canceled }

extension CargoStatusFilterX on CargoStatusFilter {
  CargoStatus? get dbStatus {
    switch (this) {
      case CargoStatusFilter.all:
        return null;
      case CargoStatusFilter.packaging:
        return CargoStatus.packaging;
      case CargoStatusFilter.delayed:
        return CargoStatus.delayed;
      case CargoStatusFilter.shipped:
        return CargoStatus.shipped;
      case CargoStatusFilter.completed:
        return CargoStatus.completed;
      case CargoStatusFilter.canceled:
        return CargoStatus.canceled;
    }
  }

  String get label {
    switch (this) {
      case CargoStatusFilter.all:
        return 'Tümü';
      case CargoStatusFilter.packaging:
        return CargoStatus.packaging.label;
      case CargoStatusFilter.delayed:
        return CargoStatus.delayed.label;
      case CargoStatusFilter.shipped:
        return CargoStatus.shipped.label;
      case CargoStatusFilter.completed:
        return CargoStatus.completed.label;
      case CargoStatusFilter.canceled:
        return CargoStatus.canceled.label;
    }
  }
}

/// Satış listesi sıralama seçenekleri.
enum SaleSortOption { dateDescending, dateAscending }

/// Satış listesi sorgu parametreleri: arama, platform/durum filtresi,
/// sıralama ve sayfalama (gereksinim 5.3, 4.3.3 — tarih/platform/durum
/// filtreleri).
class SaleQuery {
  const SaleQuery({
    this.search = '',
    this.statusFilter = CargoStatusFilter.all,
    this.profileId,
    this.sort = SaleSortOption.dateDescending,
    this.page = 0,
    this.pageSize = AppLimits.defaultPageSize,
  });

  final String search;
  final CargoStatusFilter statusFilter;

  /// Belirli bir profile ait satışları göster. `null` ise tüm profiller.
  final String? profileId;
  final SaleSortOption sort;
  final int page;
  final int pageSize;

  static const _unset = Object();

  SaleQuery copyWith({
    String? search,
    CargoStatusFilter? statusFilter,
    Object? profileId = _unset,
    SaleSortOption? sort,
    int? page,
  }) {
    return SaleQuery(
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      profileId: identical(profileId, _unset) ? this.profileId : profileId as String?,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      pageSize: pageSize,
    );
  }

  SaleQuery resetToFirstPage() => copyWith(page: 0);
}
