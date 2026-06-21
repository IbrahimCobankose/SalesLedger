/// `purchase_items` tablosunun saf domain karşılığı. Bir alışa eklenen
/// tek bir ürün kalemini temsil eder.
class PurchaseItem {
  const PurchaseItem({
    required this.id,
    required this.purchaseId,
    this.productId,
    required this.name,
    this.photoUrl,
    required this.customPurchasePrice,
    this.quantity = 1,
  });

  final String id;
  final String purchaseId;
  final String? productId;
  final String name;
  final String? photoUrl;
  final double customPurchasePrice;
  final int quantity;

  double get lineTotal => customPurchasePrice * quantity;
}
