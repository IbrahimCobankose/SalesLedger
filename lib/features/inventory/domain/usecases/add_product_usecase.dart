import 'dart:typed_data';

import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/inventory/domain/repositories/product_repository.dart';

class AddProductUseCase {
  const AddProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product> call({
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
  }) {
    return _repository.addProduct(
      name: name,
      salePrice: salePrice,
      photos: photos,
      productionCost: productionCost,
      category: category,
      initialStock: initialStock,
      length: length,
      width: width,
      height: height,
      weight: weight,
      description: description,
      notes: notes,
      tags: tags,
    );
  }
}
