/// Dışa aktarılacak rapor biçimleri (kullanıcı seçer).
enum ReportFormat { excel, word, pdf }

extension ReportFormatX on ReportFormat {
  String get fileExtension {
    switch (this) {
      case ReportFormat.excel:
        return 'xlsx';
      case ReportFormat.word:
        return 'docx';
      case ReportFormat.pdf:
        return 'pdf';
    }
  }
}

/// Biçimden bağımsız rapor içeriği: başlık + tablo (başlıklar + satırlar).
/// Tüm dışa aktarıcılar (Excel/Word/PDF) bu modeli tüketir; çağrı yerleri
/// veriyi bir kez hazırlayıp kullanıcının seçtiği biçime aktarır.
class ReportData {
  const ReportData({
    required this.fileBaseName,
    required this.title,
    required this.headers,
    required this.rows,
  });

  /// Dosya adının ön eki (ör. 'envanter'); zaman damgası eklenir.
  final String fileBaseName;

  /// Belge içi başlık (ör. 'Envanter Raporu').
  final String title;

  final List<String> headers;
  final List<List<String>> rows;
}
