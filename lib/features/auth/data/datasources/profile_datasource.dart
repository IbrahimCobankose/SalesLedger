import 'dart:typed_data';

import 'package:sales_ledger/features/auth/data/models/profile_model.dart';

/// `profiles` tablosu ve avatar depolama alanı ile iletişim kuran
/// veri kaynağı sözleşmesi.
abstract class ProfileDatasource {
  Future<List<ProfileModel>> getProfiles(String userId);

  Future<ProfileModel> insertProfile({
    required String userId,
    required String name,
    String? role,
    String? avatarUrl,
  });

  Future<void> deleteProfile(String id);

  Future<ProfileModel> updateProfile(ProfileModel profile);

  /// Avatarı Supabase Storage'a yükler ve genel erişim URL'ini döner.
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  });
}
