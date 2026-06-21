/// `shipping_status` enum'unun Dart karşılığı. Satış bağlamında 5 durumun
/// tamamı kullanılır (gereksinim 4.3.2, satışlar.html).
enum CargoStatus {
  packaging,
  delayed,
  shipped,
  completed,
  canceled;

  String get dbValue => name;

  static CargoStatus fromDbValue(String value) {
    return CargoStatus.values.firstWhere(
      (status) => status.dbValue == value,
      orElse: () => CargoStatus.packaging,
    );
  }

  String get label {
    switch (this) {
      case CargoStatus.packaging:
        return 'Kargolanıyor';
      case CargoStatus.delayed:
        return 'Geciken Kargo';
      case CargoStatus.shipped:
        return 'Kargoya Verildi';
      case CargoStatus.completed:
        return 'Satış Tamamlandı';
      case CargoStatus.canceled:
        return 'İptal Edildi';
    }
  }
}
