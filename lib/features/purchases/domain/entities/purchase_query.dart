import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_status.dart';

/// Liste filtreleme seçenekleri (alımlar.html filtre çipleri).
enum PurchaseStatusFilter { all, completed, pending, canceled }

extension PurchaseStatusFilterX on PurchaseStatusFilter {
  /// Filtreye karşılık gelen veritabanı durumları (Bekliyor üç farklı
  /// ham durumu kapsar: packaging/delayed/shipped).
  List<PurchaseStatus>? get dbStatuses {
    switch (this) {
      case PurchaseStatusFilter.all:
        return null;
      case PurchaseStatusFilter.completed:
        return [PurchaseStatus.completed];
      case PurchaseStatusFilter.pending:
        return [PurchaseStatus.packaging, PurchaseStatus.delayed, PurchaseStatus.shipped];
      case PurchaseStatusFilter.canceled:
        return [PurchaseStatus.canceled];
    }
  }
}

/// Alış listesi sorgu parametreleri: arama, durum filtresi ve sayfalama
/// (gereksinim 5.3 — sayfalandırılmış listeler).
class PurchaseQuery {
  const PurchaseQuery({
    this.search = '',
    this.statusFilter = PurchaseStatusFilter.all,
    this.page = 0,
    this.pageSize = AppLimits.defaultPageSize,
  });

  final String search;
  final PurchaseStatusFilter statusFilter;
  final int page;
  final int pageSize;

  PurchaseQuery copyWith({
    String? search,
    PurchaseStatusFilter? statusFilter,
    int? page,
  }) {
    return PurchaseQuery(
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      page: page ?? this.page,
      pageSize: pageSize,
    );
  }

  PurchaseQuery resetToFirstPage() => copyWith(page: 0);
}
