/// `shipping_status` enum'unun Dart karşılığı. Alış bağlamında yalnızca
/// `completed` (Tamamlandı), `packaging` (Bekliyor) ve `canceled`
/// (İptal Edildi) durumları kullanılır (gereksinim 4.4, alımlar.html).
enum PurchaseStatus {
  packaging,
  delayed,
  shipped,
  completed,
  canceled;

  String get dbValue => name;

  static PurchaseStatus fromDbValue(String value) {
    return PurchaseStatus.values.firstWhere(
      (status) => status.dbValue == value,
      orElse: () => PurchaseStatus.completed,
    );
  }

  String get label {
    switch (this) {
      case PurchaseStatus.completed:
        return 'Tamamlandı';
      case PurchaseStatus.canceled:
        return 'İptal Edildi';
      case PurchaseStatus.packaging:
      case PurchaseStatus.delayed:
      case PurchaseStatus.shipped:
        return 'Bekliyor';
    }
  }
}
