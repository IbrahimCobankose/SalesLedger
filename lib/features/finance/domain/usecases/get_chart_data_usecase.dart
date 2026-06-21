import 'package:sales_ledger/features/finance/domain/entities/chart_point.dart';
import 'package:sales_ledger/features/finance/domain/entities/finance_period.dart';
import 'package:sales_ledger/features/finance/domain/repositories/finance_repository.dart';

class GetChartDataUseCase {
  const GetChartDataUseCase(this._repository);

  final FinanceRepository _repository;

  Future<List<ChartPoint>> call(FinancePeriod period, DateTime reference) {
    return _repository.getChartData(period, reference);
  }
}
