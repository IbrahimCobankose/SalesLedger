import 'dart:typed_data';

import 'package:sales_ledger/features/purchases/domain/entities/purchase.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item_draft.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_query.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_status.dart';

/// Alış (tedarik) yönetimi işlemleri için soyut sözleşme.
abstract class PurchaseRepository {
  Future<List<Purchase>> getPurchases(PurchaseQuery query);

  Future<Purchase> getPurchaseById(String id);

  Future<List<PurchaseItem>> getPurchaseItems(String purchaseId);

  /// Zorunlu alanlar: ürün, alış fiyatı, miktar (gereksinim 4.4.1).
  /// Tedarikçi adı, ödeme tipi ve not opsiyoneldir.
  Future<Purchase> addPurchase({
    String? supplierName,
    required DateTime purchaseDate,
    required List<PurchaseItemDraft> items,
    String? paymentType,
    String? notes,
    List<Uint8List> photos = const [],
    PurchaseStatus status = PurchaseStatus.completed,
    String? profileId,
  });

  /// Mevcut alışı günceller. [keptPhotos] korunan mevcut fotoğraf yollarını,
  /// [newPhotos] yeni eklenecek görselleri içerir; kaldırılanlar depolamadan
  /// da silinir.
  Future<Purchase> updatePurchase({
    required String purchaseId,
    String? supplierName,
    required DateTime purchaseDate,
    required List<PurchaseItemDraft> items,
    String? paymentType,
    String? notes,
    PurchaseStatus status = PurchaseStatus.completed,
    List<String> keptPhotos = const [],
    List<Uint8List> newPhotos = const [],
  });

  Future<void> deletePurchase(String id);
}
