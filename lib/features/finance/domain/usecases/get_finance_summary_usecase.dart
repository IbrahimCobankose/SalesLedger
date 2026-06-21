import 'package:sales_ledger/features/finance/domain/entities/finance_period.dart';
import 'package:sales_ledger/features/finance/domain/entities/finance_summary.dart';
import 'package:sales_ledger/features/finance/domain/repositories/finance_repository.dart';

class GetFinanceSummaryUseCase {
  const GetFinanceSummaryUseCase(this._repository);

  final FinanceRepository _repository;

  Future<FinanceSummary> call(FinancePeriod period, DateTime reference) {
    return _repository.getSummary(period, reference);
  }
}
