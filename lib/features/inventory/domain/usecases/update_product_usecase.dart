import 'dart:typed_data';

import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/inventory/domain/repositories/product_repository.dart';

class UpdateProductUseCase {
  const UpdateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product> call(Product product, {List<Uint8List> newPhotos = const []}) =>
      _repository.updateProduct(product, newPhotos: newPhotos);
}
