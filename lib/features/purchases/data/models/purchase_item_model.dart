import 'package:sales_ledger/features/purchases/domain/entities/purchase_item.dart';

class PurchaseItemModel extends PurchaseItem {
  const PurchaseItemModel({
    required super.id,
    required super.purchaseId,
    super.productId,
    required super.name,
    super.photoUrl,
    required super.customPurchasePrice,
    super.quantity,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: json['id'] as String,
      purchaseId: json['purchase_id'] as String,
      productId: json['product_id'] as String?,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
      customPurchasePrice: (json['custom_purchase_price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toInsertJson(String purchaseId) {
    return {
      'purchase_id': purchaseId,
      'product_id': productId,
      'name': name,
      'photo_url': photoUrl,
      'custom_purchase_price': customPurchasePrice,
      'quantity': quantity,
    };
  }
}
