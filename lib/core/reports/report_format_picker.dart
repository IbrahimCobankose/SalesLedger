import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/reports/report_data.dart';

/// Kullanıcıya rapor biçimini (Excel/Word/PDF) seçtiren alt sayfa.
/// Seçim yapılmazsa `null` döner.
Future<ReportFormat?> showReportFormatPicker(BuildContext context) {
  final l10n = context.l10n;
  return showModalBottomSheet<ReportFormat>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.reportFormatTitle,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.table_view_outlined),
              title: Text(l10n.reportFormatExcel),
              onTap: () => Navigator.of(sheetContext).pop(ReportFormat.excel),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.reportFormatWord),
              onTap: () => Navigator.of(sheetContext).pop(ReportFormat.word),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(l10n.reportFormatPdf),
              onTap: () => Navigator.of(sheetContext).pop(ReportFormat.pdf),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
