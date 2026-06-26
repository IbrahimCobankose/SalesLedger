import 'dart:typed_data';

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

  /// Alış fotoğraflarını 'purchase-photos' bucket'ına yükler, public URL döner.
  Future<List<String>> uploadPhotos({
    required String userId,
    required List<Uint8List> photos,
  });

  /// Verilen public URL'lere karşılık gelen depolama nesnelerini siler.
  Future<void> deletePhotos(List<String> photoUrls);

  Future<PurchaseModel> insertPurchase({
    required PurchaseModel purchase,
    required List<PurchaseItemDraft> items,
  });

  /// Mevcut alışı ve kalemlerini günceller (kalemler tamamen yenilenir).
  Future<PurchaseModel> updatePurchase({
    required String purchaseId,
    required PurchaseModel purchase,
    required List<PurchaseItemDraft> items,
  });

  Future<void> deletePurchase(String id);
}
