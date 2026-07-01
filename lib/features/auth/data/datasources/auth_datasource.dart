/// Supabase Auth ile doğrudan iletişim kuran veri kaynağı sözleşmesi.
/// İş mantığı içermez; yalnızca ham API çağrılarını sarar.
abstract class AuthDatasource {
  /// Kayıt olur ve oluşturulan kullanıcının ID'sini döner.
  /// E-posta doğrulama açık olsa bile AuthResponse'dan ID alınabilir.
  /// [data] kullanıcı meta verisi olarak Supabase'e iletilir (ör. company_name).
  Future<String> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({required String email});

  /// Kayıt doğrulama e-postasını yeniden gönderir.
  Future<void> resendVerificationEmail({required String email});

  /// Giriş yapmış kullanıcının hesabını ve tüm verisini kalıcı olarak siler
  /// (sunucudaki `delete_current_user` fonksiyonunu çağırır).
  Future<void> deleteAccount();

  String get currentUserId;
}
