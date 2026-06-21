import 'package:sales_ledger/features/finance/domain/entities/cash_movement.dart';

/// Kasa Hareketleri sayfasındaki filtre seçenekleri: hareket türü ve
/// tarih aralığı (gereksinim 4.5.2 — sağ üstteki filtre butonu).
class CashMovementQuery {
  const CashMovementQuery({this.typeFilter, this.startDate, this.endDate});

  final CashMovementType? typeFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  CashMovementQuery copyWith({
    CashMovementType? Function()? typeFilter,
    DateTime? Function()? startDate,
    DateTime? Function()? endDate,
  }) {
    return CashMovementQuery(
      typeFilter: typeFilter != null ? typeFilter() : this.typeFilter,
      startDate: startDate != null ? startDate() : this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
    );
  }
}
