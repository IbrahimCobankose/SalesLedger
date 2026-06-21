import 'package:sales_ledger/features/inventory/domain/entities/product_sale_history_item.dart';

class ProductSaleHistoryItemModel extends ProductSaleHistoryItem {
  const ProductSaleHistoryItemModel({
    required super.saleId,
    required super.saleDate,
    required super.quantity,
    required super.lineTotal,
    required super.status,
  });

  /// `sale_items` satırı + ilişkili `sales` başlığından oluşturulur.
  factory ProductSaleHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final sale = json['sales'] as Map<String, dynamic>;
    final quantity = json['quantity'] as int? ?? 1;
    final unitPrice = (json['custom_sale_price'] as num).toDouble();

    return ProductSaleHistoryItemModel(
      saleId: sale['id'] as String,
      saleDate: DateTime.parse(sale['sale_date'] as String),
      quantity: quantity,
      lineTotal: unitPrice * quantity,
      status: sale['status'] as String,
    );
  }
}
