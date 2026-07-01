import 'package:sales_ledger/features/auth/domain/repositories/auth_repository.dart';

/// Hesabı ve tüm verisini kalıcı olarak silme iş kuralı.
class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.deleteAccount();
}
