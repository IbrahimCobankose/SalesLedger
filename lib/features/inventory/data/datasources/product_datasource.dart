import 'dart:typed_data';

import 'package:sales_ledger/features/inventory/data/models/product_model.dart';
import 'package:sales_ledger/features/inventory/data/models/product_sale_history_item_model.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_query.dart';

/// `products` tablosu ve ürün fotoğrafları depolama alanı ile iletişim
/// kuran veri kaynağı sözleşmesi.
abstract class ProductDatasource {
  Future<List<ProductModel>> getProducts(String userId, ProductQuery query);

  Future<ProductModel> getProductById(String id);

  Future<ProductModel> insertProduct(ProductModel product);

  Future<ProductModel> updateProduct(ProductModel product);

  Future<void> deleteProduct(String id);

  Future<List<String>> uploadPhotos({
    required String userId,
    required List<Uint8List> photos,
  });

  Future<List<ProductSaleHistoryItemModel>> getSaleHistory(String productId);
}
