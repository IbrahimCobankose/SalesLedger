import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_datasource.dart';
import 'package:sales_ledger/features/auth/data/datasources/profile_datasource.dart';
import 'package:sales_ledger/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authDatasource, this._profileDatasource);

  final AuthDatasource _authDatasource;
  final ProfileDatasource _profileDatasource;

  @override
  Future<void> signUp({
    required String companyName,
    required String email,
    required String password,
  }) async {
    try {
      // Şirket adı meta veri olarak saklanır; oturum açılmadan profil
      // tablosuna yazılmaz — RLS bunu engeller. İlk profil, e-posta
      // doğrulaması tamamlanıp giriş yapıldığında ProfilesNotifier tarafından
      // otomatik oluşturulur (bkz. profile_provider.dart).
      await _authDatasource.signUp(
        email: email,
        password: password,
        data: {'company_name': companyName},
      );
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e));
    } on StateError {
      throw const AppException('Hesap oluşturulamadı. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<void> resendVerificationEmail({required String email}) async {
    try {
      await _authDatasource.resendVerificationEmail(email: email);
    } on AuthException {
      throw const AppException('Doğrulama e-postası gönderilemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _authDatasource.signIn(email: email, password: password);
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authDatasource.signOut();
    } on AuthException {
      throw const AppException('Çıkış yapılırken bir sorun oluştu.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _authDatasource.sendPasswordResetEmail(email: email);
    } on AuthException {
      throw const AppException('Sıfırlama bağlantısı gönderilemedi. E-postanızı kontrol edin.');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _authDatasource.deleteAccount();
    } on PostgrestException {
      throw const AppException('Hesap silinemedi. Lütfen tekrar deneyin.');
    } catch (_) {
      throw const AppException('Hesap silinemedi. Lütfen tekrar deneyin.');
    }
    // Veri sunucuda silindi; yerel oturumu kapat. Token artık geçersiz
    // olabileceğinden çıkış hatasını yok sayıyoruz.
    try {
      await _authDatasource.signOut();
    } catch (_) {}
  }

  String _mapAuthError(AuthException e) {
    final message = e.message.toLowerCase();
    // Supabase mesaj bazlı ayırt etme (status code'lar sürüme göre değişebilir)
    if (message.contains('email already registered') ||
        message.contains('user already registered')) {
      return 'Bu e-posta adresi zaten kullanımda.';
    }
    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (message.contains('email not confirmed')) {
      return 'E-postanız henüz doğrulanmadı. Lütfen gelen kutunuzu kontrol edin.';
    }
    if (message.contains('password') && message.contains('length')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    switch (e.statusCode) {
      case '400':
        return 'E-posta veya şifre hatalı.';
      case '422':
        return 'Geçersiz e-posta adresi veya şifre.';
      case '429':
        return 'Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar deneyin.';
      default:
        return 'Bir hata oluştu, lütfen tekrar deneyin.';
    }
  }
}
