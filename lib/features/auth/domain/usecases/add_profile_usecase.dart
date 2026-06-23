import 'dart:typed_data';

import 'package:sales_ledger/features/auth/domain/entities/profile.dart';
import 'package:sales_ledger/features/auth/domain/repositories/profile_repository.dart';

/// Yeni profil oluşturma iş kuralı.
class AddProfileUseCase {
  const AddProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Profile> call({
    required String name,
    String? role,
    Uint8List? avatarBytes,
    String? avatarExtension,
  }) {
    return _repository.addProfile(
      name: name,
      role: role,
      avatarBytes: avatarBytes,
      avatarExtension: avatarExtension,
    );
  }
}
