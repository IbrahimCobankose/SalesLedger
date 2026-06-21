import 'package:sales_ledger/features/sales/domain/repositories/sale_repository.dart';

class DeleteSaleUseCase {
  const DeleteSaleUseCase(this._repository);

  final SaleRepository _repository;

  Future<void> call(String id) => _repository.deleteSale(id);
}
