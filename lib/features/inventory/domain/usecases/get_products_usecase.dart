import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_query.dart';
import 'package:sales_ledger/features/inventory/domain/repositories/product_repository.dart';

/// Filtrelenmiş/sıralanmış/sayfalandırılmış ürün listesini getirme iş kuralı.
class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call(ProductQuery query) => _repository.getProducts(query);
}
