import 'package:sales_ledger/features/purchases/domain/entities/purchase.dart';
import 'package:sales_ledger/features/purchases/domain/repositories/purchase_repository.dart';

class GetPurchaseByIdUseCase {
  const GetPurchaseByIdUseCase(this._repository);

  final PurchaseRepository _repository;

  Future<Purchase> call(String id) => _repository.getPurchaseById(id);
}
