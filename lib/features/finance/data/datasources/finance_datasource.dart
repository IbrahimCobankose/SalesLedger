/// Kasa/istatistik raporlaması için `sales`/`sale_items`/`purchases`
/// tablolarından ham veri okuyan veri kaynağı sözleşmesi. Ayrı bir
/// "finance" tablosu yoktur; raporlar mevcut satış/alış verisinden
/// türetilir (gereksinim 4.5, 4.6).
abstract class FinanceDatasource {
  /// id, sale_date, total_amount, platform, customers(name) — yalnızca
  /// kargo durumu 'completed' olan satışlar (gereksinim 4.5.1).
  Future<List<Map<String, dynamic>>> fetchCompletedSales(
    String userId,
    DateTime start,
    DateTime end,
  );

  /// id, purchase_date, total_amount, supplier_name.
  Future<List<Map<String, dynamic>>> fetchPurchases(
    String userId,
    DateTime start,
    DateTime end,
  );

  /// name, quantity, custom_sale_price — yalnızca tamamlanmış satışlara
  /// ait kalemler (en çok satan / en yüksek gelir getiren ürünler için).
  Future<List<Map<String, dynamic>>> fetchCompletedSaleItems(
    String userId,
    DateTime start,
    DateTime end,
  );
}
