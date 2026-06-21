import 'package:sales_ledger/features/inventory/domain/repositories/product_repository.dart';

class DeleteProductUseCase {
  const DeleteProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(String id) => _repository.deleteProduct(id);
}
