import 'dart:typed_data';

import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_query.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_sale_history_item.dart';

/// Envanter (ürün) yönetimi işlemleri için soyut sözleşme.
abstract class ProductRepository {
  /// [query] parametrelerine göre sayfalandırılmış ürün listesi getirir.
  Future<List<Product>> getProducts(ProductQuery query);

  Future<Product> getProductById(String id);

  /// Zorunlu alanlar: fotoğraf (≥1), ürün adı, satış fiyatı (gereksinim 4.2.2).
  Future<Product> addProduct({
    required String name,
    required double salePrice,
    required List<Uint8List> photos,
    double? productionCost,
    String? category,
    int initialStock = 0,
    double? length,
    double? width,
    double? height,
    double? weight,
    String? description,
    String? notes,
    List<String> tags = const [],
  });

  Future<Product> updateProduct(Product product);

  Future<void> deleteProduct(String id);

  Future<List<ProductSaleHistoryItem>> getSaleHistory(String productId);
}
