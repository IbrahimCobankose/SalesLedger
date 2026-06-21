import 'dart:typed_data';

import 'package:sales_ledger/features/auth/domain/entities/profile.dart';

/// Profil yönetimi işlemleri için soyut sözleşme.
abstract class ProfileRepository {
  /// Aktif hesaba bağlı tüm profilleri getirir.
  Future<List<Profile>> getProfiles();

  /// Yeni profil oluşturur. [avatarBytes] verilirse önce Supabase
  /// Storage'a yüklenir, dönen URL profile kaydedilir.
  Future<Profile> addProfile({
    required String name,
    String? role,
    Uint8List? avatarBytes,
  });

  Future<void> deleteProfile(String id);

  Future<Profile> updateProfile(Profile profile);
}
