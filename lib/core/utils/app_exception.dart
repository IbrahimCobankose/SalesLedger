/// Teknik hatalardan (Supabase/Postgrest/Auth) türetilen, kullanıcıya
/// gösterilmeye uygun Türkçe mesaj taşıyan tek tip hata sınıfı.
///
/// Repository implementasyonları dışarıya yalnızca bu tipi fırlatır;
/// presentation katmanı teknik detaylara asla erişmez.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
