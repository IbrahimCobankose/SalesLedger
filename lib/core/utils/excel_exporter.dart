import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_ledger/features/finance/domain/entities/chart_point.dart';
import 'package:sales_ledger/features/finance/domain/entities/finance_summary.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale.dart';

/// Envanter/alış/satış listelerini ve kasa özet raporunu .xlsx dosyası
/// olarak cihaza indirir (gereksinim 4.2.1, 4.3.3, 4.4.2 ve 4.5.1).
abstract class ExcelExporter {
  static Future<String> exportProducts(List<Product> products) async {
    final workbook = Excel.createExcel();
    final sheet = workbook[workbook.getDefaultSheet()!];

    sheet.appendRow([
      TextCellValue('Ürün Adı'),
      TextCellValue('Kategori'),
      TextCellValue('Satış Fiyatı'),
      TextCellValue('Maliyet'),
      TextCellValue('Stok Adedi'),
      TextCellValue('Satış Adedi'),
    ]);

    for (final product in products) {
      sheet.appendRow([
        TextCellValue(product.name),
        TextCellValue(product.category ?? ''),
        DoubleCellValue(product.salePrice),
        DoubleCellValue(product.productionCost ?? 0),
        IntCellValue(product.stockQuantity),
        IntCellValue(product.soldCount),
      ]);
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw const FormatException('Excel dosyası oluşturulamadı.');
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/envanter_$timestamp.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  static Future<String> exportPurchases(List<Purchase> purchases) async {
    final workbook = Excel.createExcel();
    final sheet = workbook[workbook.getDefaultSheet()!];

    sheet.appendRow([
      TextCellValue('Tedarikçi'),
      TextCellValue('Tarih'),
      TextCellValue('Durum'),
      TextCellValue('Ödeme Tipi'),
      TextCellValue('Kalem Sayısı'),
      TextCellValue('Toplam Tutar'),
    ]);

    for (final purchase in purchases) {
      sheet.appendRow([
        TextCellValue(purchase.displaySupplierName),
        TextCellValue(purchase.purchaseDate.toIso8601String()),
        TextCellValue(purchase.status.label),
        TextCellValue(purchase.paymentType ?? ''),
        IntCellValue(purchase.itemCount),
        DoubleCellValue(purchase.totalAmount),
      ]);
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw const FormatException('Excel dosyası oluşturulamadı.');
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/alimlar_$timestamp.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  static Future<String> exportSales(List<Sale> sales) async {
    final workbook = Excel.createExcel();
    final sheet = workbook[workbook.getDefaultSheet()!];

    sheet.appendRow([
      TextCellValue('Müşteri'),
      TextCellValue('Platform'),
      TextCellValue('Tarih'),
      TextCellValue('Durum'),
      TextCellValue('Kalem Sayısı'),
      TextCellValue('Toplam Tutar'),
    ]);

    for (final sale in sales) {
      sheet.appendRow([
        TextCellValue(sale.displayCustomerName),
        TextCellValue(sale.platform ?? ''),
        TextCellValue(sale.saleDate.toIso8601String()),
        TextCellValue(sale.status.label),
        IntCellValue(sale.itemCount),
        DoubleCellValue(sale.totalAmount),
      ]);
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw const FormatException('Excel dosyası oluşturulamadı.');
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/satislar_$timestamp.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  /// "Rapor Al" eylemi (gereksinim 4.5.1): özet kasa raporu.
  static Future<String> exportFinanceSummary({
    required String periodLabel,
    required FinanceSummary summary,
    required List<ChartPoint> chartData,
  }) async {
    final workbook = Excel.createExcel();
    final sheet = workbook[workbook.getDefaultSheet()!];

    sheet.appendRow([TextCellValue('Kasa Özeti'), TextCellValue(periodLabel)]);
    sheet.appendRow([TextCellValue('Toplam Gelir'), DoubleCellValue(summary.totalIncome)]);
    sheet.appendRow([TextCellValue('Toplam Gider'), DoubleCellValue(summary.totalExpense)]);
    sheet.appendRow([TextCellValue('Net Kâr'), DoubleCellValue(summary.netProfit)]);
    sheet.appendRow([]);
    sheet.appendRow([TextCellValue('Periyot'), TextCellValue('Gelir'), TextCellValue('Gider')]);

    for (final point in chartData) {
      sheet.appendRow([
        TextCellValue(point.label),
        DoubleCellValue(point.income),
        DoubleCellValue(point.expense),
      ]);
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw const FormatException('Excel dosyası oluşturulamadı.');
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/kasa_raporu_$timestamp.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }
}
