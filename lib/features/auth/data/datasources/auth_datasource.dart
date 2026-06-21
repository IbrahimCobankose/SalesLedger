/// Supabase Auth ile doğrudan iletişim kuran veri kaynağı sözleşmesi.
/// İş mantığı içermez; yalnızca ham API çağrılarını sarar.
abstract class AuthDatasource {
  Future<void> signUp({required String email, required String password});

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({required String email});

  String get currentUserId;
}
