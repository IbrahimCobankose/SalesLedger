/// Kasa ve İstatistikler ana sayfasındaki özet kartların verisi
/// (gereksinim 4.5.1). Yalnızca kargo durumu "Satış Tamamlandı" olan
/// satışlar gelire dahil edilir; alışların tamamı gidere dahildir.
class FinanceSummary {
  const FinanceSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.previousNetProfit,
  });

  final double totalIncome;
  final double totalExpense;
  final double previousNetProfit;

  double get netProfit => totalIncome - totalExpense;

  /// Önceki döneme göre değişim yüzdesi; önceki dönem net kârı 0 ise
  /// karşılaştırma anlamsız olduğundan null döner.
  double? get changePercentVsPreviousPeriod {
    if (previousNetProfit == 0) return null;
    return (netProfit - previousNetProfit) / previousNetProfit.abs() * 100;
  }
}
