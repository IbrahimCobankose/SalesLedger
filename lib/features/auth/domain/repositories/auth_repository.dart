/// Kimlik doğrulama işlemleri için soyut sözleşme.
///
/// Yalnızca data/repositories/auth_repository_impl.dart tarafından
/// implemente edilir; presentation katmanı bu arayüze bağımlıdır.
abstract class AuthRepository {
  /// Yeni hesap oluşturur. Şirket adı, ilk profil olarak [profiles]
  /// tablosuna kaydedilir (gereksinim 4.1.1).
  Future<void> signUp({
    required String companyName,
    required String email,
    required String password,
  });

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({required String email});
}
