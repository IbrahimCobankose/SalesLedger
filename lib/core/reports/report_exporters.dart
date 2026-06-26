import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sales_ledger/core/reports/report_data.dart';

/// Rapor verisini kullanıcının seçtiği biçime aktaran cephe (facade).
abstract class ReportExporter {
  static Future<String> export(ReportData data, ReportFormat format) {
    switch (format) {
      case ReportFormat.excel:
        return _ExcelReportExporter.export(data);
      case ReportFormat.word:
        return _WordReportExporter.export(data);
      case ReportFormat.pdf:
        return _PdfReportExporter.export(data);
    }
  }
}

Future<String> _writeFile(String baseName, String ext, List<int> bytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final file = File('${directory.path}/${baseName}_$timestamp.$ext');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

// ── Excel ────────────────────────────────────────────────────────────────
abstract class _ExcelReportExporter {
  static Future<String> export(ReportData data) async {
    final workbook = Excel.createExcel();
    final sheet = workbook[workbook.getDefaultSheet()!];
    sheet.appendRow(data.headers.map((h) => TextCellValue(h)).toList());
    for (final row in data.rows) {
      sheet.appendRow(row.map((c) => TextCellValue(c)).toList());
    }
    final bytes = workbook.encode();
    if (bytes == null) {
      throw const FormatException('Excel dosyası oluşturulamadı.');
    }
    return _writeFile(data.fileBaseName, ReportFormat.excel.fileExtension, bytes);
  }
}

// ── PDF (Roboto fontu ile Türkçe karakter desteği) ─────────────────────────
abstract class _PdfReportExporter {
  static Future<String> export(ReportData data) async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (context) => [
          pw.Header(level: 0, text: data.title),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: data.headers,
            data: data.rows,
            headerStyle: pw.TextStyle(font: bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(4),
          ),
        ],
      ),
    );
    final bytes = await doc.save();
    return _writeFile(data.fileBaseName, ReportFormat.pdf.fileExtension, bytes);
  }
}

// ── Word (.docx) — Open XML paketini elle (archive ile) üretir ─────────────
abstract class _WordReportExporter {
  static Future<String> export(ReportData data) async {
    final archive = Archive();
    void add(String name, String content) {
      final bytes = utf8.encode(content);
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    add('[Content_Types].xml', _contentTypesXml);
    add('_rels/.rels', _relsXml);
    add('word/document.xml', _documentXml(data));

    final zipped = ZipEncoder().encode(archive);
    if (zipped == null) {
      throw const FormatException('Word dosyası oluşturulamadı.');
    }
    return _writeFile(data.fileBaseName, ReportFormat.word.fileExtension, zipped);
  }

  static String _esc(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  static String _cell(String text, {bool bold = false}) {
    final runProps = bold ? '<w:rPr><w:b/></w:rPr>' : '';
    return '<w:tc><w:tcPr/><w:p><w:r>$runProps'
        '<w:t xml:space="preserve">${_esc(text)}</w:t></w:r></w:p></w:tc>';
  }

  static String _documentXml(ReportData data) {
    final buffer = StringBuffer()
      ..write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
      ..write('<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">')
      ..write('<w:body>')
      // Başlık
      ..write('<w:p><w:r><w:rPr><w:b/><w:sz w:val="32"/></w:rPr>')
      ..write('<w:t xml:space="preserve">${_esc(data.title)}</w:t></w:r></w:p>')
      // Tablo
      ..write('<w:tbl><w:tblPr><w:tblW w:w="0" w:type="auto"/><w:tblBorders>');
    for (final side in ['top', 'left', 'bottom', 'right', 'insideH', 'insideV']) {
      buffer.write('<w:$side w:val="single" w:sz="4" w:space="0" w:color="auto"/>');
    }
    buffer.write('</w:tblBorders></w:tblPr>');

    // Başlık satırı
    buffer.write('<w:tr>');
    for (final header in data.headers) {
      buffer.write(_cell(header, bold: true));
    }
    buffer.write('</w:tr>');

    // Veri satırları
    for (final row in data.rows) {
      buffer.write('<w:tr>');
      for (final value in row) {
        buffer.write(_cell(value));
      }
      buffer.write('</w:tr>');
    }

    buffer.write('</w:tbl></w:body></w:document>');
    return buffer.toString();
  }

  static const _contentTypesXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/word/document.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
      '</Types>';

  static const _relsXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" '
      'Target="word/document.xml"/>'
      '</Relationships>';
}
