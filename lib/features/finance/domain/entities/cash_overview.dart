/// Kasa Hareketleri sayfasındaki hero kart verisi (gereksinim 4.5.2).
class CashOverview {
  const CashOverview({
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
  });

  final double totalBalance;
  final double monthIncome;
  final double monthExpense;
}
