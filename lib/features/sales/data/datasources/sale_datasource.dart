import 'package:sales_ledger/features/sales/data/models/sale_item_model.dart';
import 'package:sales_ledger/features/sales/data/models/sale_model.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item_draft.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_query.dart';

/// `sales`/`sale_items`/`customers` tabloları ile iletişim kuran veri
/// kaynağı sözleşmesi.
abstract class SaleDatasource {
  Future<List<SaleModel>> getSales(String userId, SaleQuery query);

  Future<SaleModel> getSaleById(String id);

  Future<List<SaleItemModel>> getSaleItems(String saleId);

  /// [customerName] verilmişse, bu kullanıcı için aynı adda bir müşteri
  /// varsa onu kullanır; yoksa yeni bir müşteri kaydı oluşturur
  /// ("tekrarlayan müşteriler sistemde kayıtlı tutulabilir").
  Future<String?> findOrCreateCustomer({required String userId, required String name});

  Future<SaleModel> insertSale({
    required SaleModel sale,
    required List<SaleItemDraft> items,
  });

  Future<void> deleteSale(String id);
}
