import 'dart:typed_data';

import 'package:sales_ledger/features/auth/domain/entities/profile.dart';

/// Profil yönetimi işlemleri için soyut sözleşme.
abstract class ProfileRepository {
  /// Aktif hesaba bağlı tüm profilleri getirir.
  Future<List<Profile>> getProfiles();

  /// Yeni profil oluşturur. [avatarBytes] verilirse önce Supabase
  /// Storage'a yüklenir, dönen URL profile kaydedilir.
  /// [avatarExtension] dosya uzantısını belirtir (jpg, png, vb.).
  Future<Profile> addProfile({
    required String name,
    String? role,
    Uint8List? avatarBytes,
    String? avatarExtension,
  });

  Future<void> deleteProfile(String id);

  /// Profili günceller. [newAvatarBytes] verilirse önce Storage'a yüklenir
  /// ve dönen URL profile yazılır; verilmezse mevcut avatar korunur.
  Future<Profile> updateProfile(
    Profile profile, {
    Uint8List? newAvatarBytes,
    String? avatarExtension,
  });
}
