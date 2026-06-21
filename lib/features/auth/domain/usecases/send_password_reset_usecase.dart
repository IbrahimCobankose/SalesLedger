import 'package:sales_ledger/features/auth/domain/repositories/auth_repository.dart';

/// "Şifremi Unuttum" akışını başlatan iş kuralı.
class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}
