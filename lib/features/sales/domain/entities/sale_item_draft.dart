/// Satış ekleme formundaki tek bir ürün satırı için girdi taslağı.
class SaleItemDraft {
  const SaleItemDraft({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.productId,
  });

  final String? productId;
  final String name;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;
}
