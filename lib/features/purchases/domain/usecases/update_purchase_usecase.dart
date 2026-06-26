import 'dart:typed_data';

import 'package:sales_ledger/features/purchases/domain/entities/purchase.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item_draft.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_status.dart';
import 'package:sales_ledger/features/purchases/domain/repositories/purchase_repository.dart';

class UpdatePurchaseUseCase {
  const UpdatePurchaseUseCase(this._repository);

  final PurchaseRepository _repository;

  Future<Purchase> call({
    required String purchaseId,
    String? supplierName,
    required DateTime purchaseDate,
    required List<PurchaseItemDraft> items,
    String? paymentType,
    String? notes,
    PurchaseStatus status = PurchaseStatus.completed,
    List<String> keptPhotos = const [],
    List<Uint8List> newPhotos = const [],
  }) {
    return _repository.updatePurchase(
      purchaseId: purchaseId,
      supplierName: supplierName,
      purchaseDate: purchaseDate,
      items: items,
      paymentType: paymentType,
      notes: notes,
      status: status,
      keptPhotos: keptPhotos,
      newPhotos: newPhotos,
    );
  }
}
