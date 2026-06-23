/// Kimlik doğrulama işlemleri için soyut sözleşme.
///
/// Yalnızca data/repositories/auth_repository_impl.dart tarafından
/// implemente edilir; presentation katmanı bu arayüze bağımlıdır.
abstract class AuthRepository {
  /// Yeni hesap oluşturur. Şirket adı, kullanıcı meta verisi olarak Supabase'e
  /// kaydedilir; ilk profil, e-posta doğrulaması sonrası ilk girişte oluşturulur.
  Future<void> signUp({
    required String companyName,
    required String email,
    required String password,
  });

  /// Kayıt doğrulama e-postasını yeniden gönderir.
  Future<void> resendVerificationEmail({required String email});

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({required String email});
}
