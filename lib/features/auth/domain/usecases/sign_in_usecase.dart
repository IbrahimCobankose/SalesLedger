import 'package:sales_ledger/features/auth/domain/repositories/auth_repository.dart';

/// E-posta/şifre ile giriş yapma iş kuralı.
class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) {
    return _repository.signIn(email: email, password: password);
  }
}
