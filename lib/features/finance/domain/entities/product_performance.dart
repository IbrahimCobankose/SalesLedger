/// "En çok satan ürünler" / "En yüksek gelir getiren ürünler" listeleri
/// için ürün başına satış performansı (gereksinim 4.6).
class ProductPerformance {
  const ProductPerformance({
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });

  final String productName;
  final int quantitySold;
  final double revenue;
}
