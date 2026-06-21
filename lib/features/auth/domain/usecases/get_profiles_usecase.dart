import 'package:sales_ledger/features/auth/domain/entities/profile.dart';
import 'package:sales_ledger/features/auth/domain/repositories/profile_repository.dart';

/// Aktif hesaba bağlı profilleri listeleme iş kuralı.
class GetProfilesUseCase {
  const GetProfilesUseCase(this._repository);

  final ProfileRepository _repository;

  Future<List<Profile>> call() => _repository.getProfiles();
}
