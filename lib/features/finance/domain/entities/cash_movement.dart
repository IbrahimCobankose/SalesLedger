/// Kasa hareketi türü: satıştan gelir veya alıştan gider.
enum CashMovementType { income, expense }

/// Kasa Hareketleri listesindeki tek bir satır. Ayrı bir tabloda
/// saklanmaz; tamamlanmış satışlar (gelir) ve alışlar (gider)
/// birleştirilip tarihe göre sıralanarak türetilir (gereksinim 4.5.2).
class CashMovement {
  const CashMovement({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
  });

  final String id;
  final CashMovementType type;
  final String title;
  final double amount;
  final DateTime date;
}
