import 'package:sales_ledger/features/finance/domain/entities/cash_movement.dart';
import 'package:sales_ledger/features/finance/domain/entities/cash_movement_query.dart';
import 'package:sales_ledger/features/finance/domain/repositories/finance_repository.dart';

class GetCashMovementsUseCase {
  const GetCashMovementsUseCase(this._repository);

  final FinanceRepository _repository;

  Future<List<CashMovement>> call(CashMovementQuery query) => _repository.getCashMovements(query);
}
