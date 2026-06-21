import 'package:sales_ledger/features/finance/domain/entities/cash_overview.dart';
import 'package:sales_ledger/features/finance/domain/repositories/finance_repository.dart';

class GetCashOverviewUseCase {
  const GetCashOverviewUseCase(this._repository);

  final FinanceRepository _repository;

  Future<CashOverview> call() => _repository.getCashOverview();
}
