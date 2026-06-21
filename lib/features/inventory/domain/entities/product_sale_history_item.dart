/// Ürün detay sayfasında gösterilen, o ürüne ait geçmiş satış kaydı
/// (gereksinim 4.2.3). `sale_items` ve `sales` tablolarının salt-okunur,
/// sadeleştirilmiş bir izdüşümüdür; satış modülünün kendi domain'ine
/// bağımlı değildir.
class ProductSaleHistoryItem {
  const ProductSaleHistoryItem({
    required this.saleId,
    required this.saleDate,
    required this.quantity,
    required this.lineTotal,
    required this.status,
  });

  final String saleId;
  final DateTime saleDate;
  final int quantity;
  final double lineTotal;
  final String status;
}
