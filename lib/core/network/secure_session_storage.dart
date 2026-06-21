import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase oturum (JWT) verisini şifreli olarak cihazda saklar.
///
/// Gereksinim 3.1: "JWT token'lar flutter_secure_storage içinde
/// şifreli olarak saklanır." [Supabase.initialize] çağrısına
/// `authOptions: FlutterAuthClientOptions(localStorage: SecureSessionStorage())`
/// olarak verilir.
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage() : super();

  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'supabase.session';

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async {
    return (await _storage.read(key: _sessionKey)) != null;
  }

  @override
  Future<String?> accessToken() => _storage.read(key: _sessionKey);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _sessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _sessionKey, value: persistSessionString);
}
