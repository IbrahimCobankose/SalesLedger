/// Gelir/Gider çubuk grafiğindeki tek bir periyot kovası (gereksinim 4.5.1,
/// 4.6 — haftalık/aylık/yıllık grafik gösterimi).
class ChartPoint {
  const ChartPoint({required this.label, required this.income, required this.expense});

  final String label;
  final double income;
  final double expense;
}
