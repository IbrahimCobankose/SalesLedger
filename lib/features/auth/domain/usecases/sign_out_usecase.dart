import 'package:sales_ledger/features/auth/domain/repositories/auth_repository.dart';

/// Oturumu sonlandırma iş kuralı.
class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
