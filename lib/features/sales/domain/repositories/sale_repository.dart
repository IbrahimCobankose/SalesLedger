import 'package:sales_ledger/features/sales/domain/entities/cargo_status.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item_draft.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_query.dart';

/// Satış yönetimi işlemleri için soyut sözleşme.
abstract class SaleRepository {
  Future<List<Sale>> getSales(SaleQuery query);

  Future<Sale> getSaleById(String id);

  Future<List<SaleItem>> getSaleItems(String saleId);

  /// Zorunlu alanlar: en az 1 ürün kalemi (gereksinim 4.3.3). Müşteri adı
  /// girilirse, mevcut müşteri yoksa otomatik olarak oluşturulur ve
  /// tekrar kullanılır ("tekrarlayan müşteriler sistemde kayıtlı tutulabilir").
  Future<Sale> addSale({
    String? customerName,
    required DateTime saleDate,
    String? platform,
    required List<SaleItemDraft> items,
    CargoStatus status = CargoStatus.packaging,
    String? trackingNumber,
    String? notes,
    String? profileId,
  });

  /// Mevcut bir satışı ve kalemlerini günceller.
  Future<Sale> updateSale({
    required String saleId,
    String? customerName,
    required DateTime saleDate,
    String? platform,
    required List<SaleItemDraft> items,
    CargoStatus status = CargoStatus.packaging,
    String? trackingNumber,
    String? notes,
  });

  Future<void> deleteSale(String id);
}
