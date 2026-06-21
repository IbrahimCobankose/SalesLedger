import 'package:sales_ledger/features/purchases/domain/entities/purchase.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_query.dart';
import 'package:sales_ledger/features/purchases/domain/repositories/purchase_repository.dart';

class GetPurchasesUseCase {
  const GetPurchasesUseCase(this._repository);

  final PurchaseRepository _repository;

  Future<List<Purchase>> call(PurchaseQuery query) => _repository.getPurchases(query);
}
