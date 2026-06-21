/// Alış ekleme formundaki tek bir ürün satırı için girdi taslağı.
/// Henüz kaydedilmemiştir; [PurchaseRepository.addPurchase] ile birlikte
/// gönderilir.
class PurchaseItemDraft {
  const PurchaseItemDraft({
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
