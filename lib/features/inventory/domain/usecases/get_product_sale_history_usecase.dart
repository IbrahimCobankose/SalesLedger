import 'package:sales_ledger/features/inventory/domain/entities/product_sale_history_item.dart';
import 'package:sales_ledger/features/inventory/domain/repositories/product_repository.dart';

class GetProductSaleHistoryUseCase {
  const GetProductSaleHistoryUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<ProductSaleHistoryItem>> call(String productId) {
    return _repository.getSaleHistory(productId);
  }
}
