import 'package:sales_ledger/features/purchases/data/models/purchase_item_model.dart';
import 'package:sales_ledger/features/purchases/data/models/purchase_model.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item_draft.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_query.dart';

/// `purchases`/`purchase_items` tabloları ile iletişim kuran veri kaynağı
/// sözleşmesi.
abstract class PurchaseDatasource {
  Future<List<PurchaseModel>> getPurchases(String userId, PurchaseQuery query);

  Future<PurchaseModel> getPurchaseById(String id);

  Future<List<PurchaseItemModel>> getPurchaseItems(String purchaseId);

  Future<PurchaseModel> insertPurchase({
    required PurchaseModel purchase,
    required List<PurchaseItemDraft> items,
  });

  Future<void> deletePurchase(String id);
}
