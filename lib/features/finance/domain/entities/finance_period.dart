/// Kasa ve İstatistikler ekranındaki periyot seçici (gereksinim 4.5.1).
/// Varsayılan periyot [monthly]'dir.
enum FinancePeriod { daily, weekly, monthly, yearly }

extension FinancePeriodX on FinancePeriod {
  String get label {
    switch (this) {
      case FinancePeriod.daily:
        return 'Günlük';
      case FinancePeriod.weekly:
        return 'Haftalık';
      case FinancePeriod.monthly:
        return 'Aylık';
      case FinancePeriod.yearly:
        return 'Yıllık';
    }
  }

  /// [reference] tarihini içeren periyodun başlangıç ve bitiş anları.
  ({DateTime start, DateTime end}) rangeFor(DateTime reference) {
    switch (this) {
      case FinancePeriod.daily:
        final start = DateTime(reference.year, reference.month, reference.day);
        return (start: start, end: start.add(const Duration(days: 1)));
      case FinancePeriod.weekly:
        final start = DateTime(reference.year, reference.month, reference.day)
            .subtract(Duration(days: reference.weekday - 1));
        return (start: start, end: start.add(const Duration(days: 7)));
      case FinancePeriod.monthly:
        final start = DateTime(reference.year, reference.month, 1);
        final end = DateTime(reference.year, reference.month + 1, 1);
        return (start: start, end: end);
      case FinancePeriod.yearly:
        return (start: DateTime(reference.year, 1, 1), end: DateTime(reference.year + 1, 1, 1));
    }
  }

  /// Önceki periyodun aynı süreli aralığı ("geçen döneme göre" karşılaştırması).
  ({DateTime start, DateTime end}) previousRangeFor(DateTime reference) {
    final current = rangeFor(reference);
    final duration = current.end.difference(current.start);
    return (start: current.start.subtract(duration), end: current.start);
  }

  /// Gelir/gider çubuk grafiğindeki alt periyot (kova) sayısı.
  int get bucketCount {
    switch (this) {
      case FinancePeriod.daily:
        return 1;
      case FinancePeriod.weekly:
        return 7;
      case FinancePeriod.monthly:
        return 4;
      case FinancePeriod.yearly:
        return 12;
    }
  }
}
