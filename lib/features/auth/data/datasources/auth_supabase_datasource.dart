import 'package:sales_ledger/features/auth/data/datasources/auth_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSupabaseDatasource implements AuthDatasource {
  AuthSupabaseDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<String> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
    final id = res.user?.id;
    if (id == null) {
      throw StateError('Kayıt yanıtından kullanıcı ID alınamadı.');
    }
    return id;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> resendVerificationEmail({required String email}) {
    return _client.auth.resend(type: OtpType.signup, email: email);
  }

  @override
  String get currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('Aktif oturum bulunamadı.');
    }
    return id;
  }
}
