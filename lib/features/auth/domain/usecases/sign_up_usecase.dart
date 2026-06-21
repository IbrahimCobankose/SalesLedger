import 'package:sales_ledger/features/auth/domain/repositories/auth_repository.dart';

/// Şirket adı, e-posta ve şifre ile yeni hesap oluşturma iş kuralı.
class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String companyName,
    required String email,
    required String password,
  }) {
    return _repository.signUp(
      companyName: companyName,
      email: email,
      password: password,
    );
  }
}
