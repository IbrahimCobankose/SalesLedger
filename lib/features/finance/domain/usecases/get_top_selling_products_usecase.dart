import 'package:sales_ledger/features/finance/domain/entities/finance_period.dart';
import 'package:sales_ledger/features/finance/domain/entities/product_performance.dart';
import 'package:sales_ledger/features/finance/domain/repositories/finance_repository.dart';

class GetTopSellingProductsUseCase {
  const GetTopSellingProductsUseCase(this._repository);

  final FinanceRepository _repository;

  Future<List<ProductPerformance>> call(FinancePeriod period, DateTime reference) {
    return _repository.getTopSellingProducts(period, reference);
  }
}
