import 'package:sales_ledger/features/purchases/domain/entities/purchase_item.dart';
import 'package:sales_ledger/features/purchases/domain/repositories/purchase_repository.dart';

class GetPurchaseItemsUseCase {
  const GetPurchaseItemsUseCase(this._repository);

  final PurchaseRepository _repository;

  Future<List<PurchaseItem>> call(String purchaseId) => _repository.getPurchaseItems(purchaseId);
}
