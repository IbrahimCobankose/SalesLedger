import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_ledger/core/network/supabase_client.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:sales_ledger/features/auth/data/datasources/profile_supabase_datasource.dart';
import 'package:sales_ledger/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sales_ledger/features/auth/domain/repositories/auth_repository.dart';
import 'package:sales_ledger/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:sales_ledger/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:sales_ledger/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:sales_ledger/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase istemcisi → Datasource → Repository → UseCase → Notifier zinciri.

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    AuthSupabaseDatasource(supabase),
    ProfileSupabaseDatasource(supabase),
  );
});

final signInUseCaseProvider = Provider(
  (ref) => SignInUseCase(ref.watch(authRepositoryProvider)),
);

final signUpUseCaseProvider = Provider(
  (ref) => SignUpUseCase(ref.watch(authRepositoryProvider)),
);

final signOutUseCaseProvider = Provider(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

final sendPasswordResetUseCaseProvider = Provider(
  (ref) => SendPasswordResetUseCase(ref.watch(authRepositoryProvider)),
);

/// Oturum durumunu (Supabase [AuthState] akışı) tüm uygulamaya yayar.
/// GoRouter'ın `redirect` mantığı bu provider'ı dinler.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

/// Giriş/kayıt/çıkış formlarındaki yüklenme ve hata durumunu yönetir.
/// Hata mesajları her zaman [AppException] üzerinden kullanıcı dostu Türkçe metindir.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await ref.read(signInUseCaseProvider)(email: email, password: password);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> signUp({
    required String companyName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(signUpUseCaseProvider)(
        companyName: companyName,
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(signOutUseCaseProvider)();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
