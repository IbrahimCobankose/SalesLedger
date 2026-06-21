import 'package:sales_ledger/features/sales/domain/entities/sale_item.dart';

class SaleItemModel extends SaleItem {
  const SaleItemModel({
    required super.id,
    required super.saleId,
    super.productId,
    required super.name,
    super.photoUrl,
    required super.customSalePrice,
    super.quantity,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'] as String,
      saleId: json['sale_id'] as String,
      productId: json['product_id'] as String?,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
      customSalePrice: (json['custom_sale_price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}
