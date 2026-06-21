import 'package:sales_ledger/features/sales/domain/entities/sale_item.dart';
import 'package:sales_ledger/features/sales/domain/repositories/sale_repository.dart';

class GetSaleItemsUseCase {
  const GetSaleItemsUseCase(this._repository);

  final SaleRepository _repository;

  Future<List<SaleItem>> call(String saleId) => _repository.getSaleItems(saleId);
}
