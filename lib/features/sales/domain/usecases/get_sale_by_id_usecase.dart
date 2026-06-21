import 'package:sales_ledger/features/sales/domain/entities/sale.dart';
import 'package:sales_ledger/features/sales/domain/repositories/sale_repository.dart';

class GetSaleByIdUseCase {
  const GetSaleByIdUseCase(this._repository);

  final SaleRepository _repository;

  Future<Sale> call(String id) => _repository.getSaleById(id);
}
