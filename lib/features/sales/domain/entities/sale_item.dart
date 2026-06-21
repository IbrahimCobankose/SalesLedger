/// `sale_items` tablosunun saf domain karşılığı. Bir satışa eklenen tek bir
/// ürün kalemini temsil eder. Fiyat/ölçü yalnızca bu satış için geçerlidir;
/// envanterdeki ürünü etkilemez (gereksinim 4.3.3).
class SaleItem {
  const SaleItem({
    required this.id,
    required this.saleId,
    this.productId,
    required this.name,
    this.photoUrl,
    required this.customSalePrice,
    this.quantity = 1,
  });

  final String id;
  final String saleId;
  final String? productId;
  final String name;
  final String? photoUrl;
  final double customSalePrice;
  final int quantity;

  double get lineTotal => customSalePrice * quantity;
}
