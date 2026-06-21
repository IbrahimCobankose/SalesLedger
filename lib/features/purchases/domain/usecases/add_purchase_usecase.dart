import 'package:sales_ledger/features/purchases/domain/entities/purchase.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item_draft.dart';
import 'package:sales_ledger/features/purchases/domain/repositories/purchase_repository.dart';

class AddPurchaseUseCase {
  const AddPurchaseUseCase(this._repository);

  final PurchaseRepository _repository;

  Future<Purchase> call({
    String? supplierName,
    required DateTime purchaseDate,
    required List<PurchaseItemDraft> items,
    String? paymentType,
    String? notes,
  }) {
    return _repository.addPurchase(
      supplierName: supplierName,
      purchaseDate: purchaseDate,
      items: items,
      paymentType: paymentType,
      notes: notes,
    );
  }
}
