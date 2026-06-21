import 'package:sales_ledger/features/purchases/domain/repositories/purchase_repository.dart';

class DeletePurchaseUseCase {
  const DeletePurchaseUseCase(this._repository);

  final PurchaseRepository _repository;

  Future<void> call(String id) => _repository.deletePurchase(id);
}
