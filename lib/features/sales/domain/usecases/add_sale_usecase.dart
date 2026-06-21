import 'package:sales_ledger/features/sales/domain/entities/cargo_status.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item_draft.dart';
import 'package:sales_ledger/features/sales/domain/repositories/sale_repository.dart';

class AddSaleUseCase {
  const AddSaleUseCase(this._repository);

  final SaleRepository _repository;

  Future<Sale> call({
    String? customerName,
    required DateTime saleDate,
    String? platform,
    required List<SaleItemDraft> items,
    CargoStatus status = CargoStatus.packaging,
    String? trackingNumber,
    String? notes,
  }) {
    return _repository.addSale(
      customerName: customerName,
      saleDate: saleDate,
      platform: platform,
      items: items,
      status: status,
      trackingNumber: trackingNumber,
      notes: notes,
    );
  }
}
