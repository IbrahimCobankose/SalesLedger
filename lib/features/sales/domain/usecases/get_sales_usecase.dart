import 'package:sales_ledger/features/sales/domain/entities/sale.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_query.dart';
import 'package:sales_ledger/features/sales/domain/repositories/sale_repository.dart';

class GetSalesUseCase {
  const GetSalesUseCase(this._repository);

  final SaleRepository _repository;

  Future<List<Sale>> call(SaleQuery query) => _repository.getSales(query);
}
