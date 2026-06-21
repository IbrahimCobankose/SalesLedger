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
      await _authDatasource.signUp(email: email, password: password);
      // Hesap oluşturulduğunda şirket adı ilk profil olarak kaydedilir (gereksinim 4.1.1).
      await _profileDatasource.insertProfile(
        userId: _authDatasource.currentUserId,
        name: companyName,
      );
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e));
    } on PostgrestException {
      throw const AppException('Hesap oluşturuldu ancak profil kaydedilemedi. Lütfen tekrar deneyin.');
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

  String _mapAuthError(AuthException e) {
    switch (e.statusCode) {
      case '400':
      case '422':
        return 'E-posta veya şifre hatalı.';
      case '429':
        return 'Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar deneyin.';
      default:
        return 'Bir hata oluştu, lütfen tekrar deneyin.';
    }
  }
}
