import 'dart:typed_data';

import 'package:sales_ledger/features/auth/data/datasources/profile_datasource.dart';
import 'package:sales_ledger/features/auth/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSupabaseDatasource implements ProfileDatasource {
  ProfileSupabaseDatasource(this._client);

  final SupabaseClient _client;
  static const _avatarBucket = 'avatars';

  @override
  Future<List<ProfileModel>> getProfiles(String userId) async {
    final rows = await _client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return rows.map((row) => ProfileModel.fromJson(row)).toList();
  }

  @override
  Future<ProfileModel> insertProfile({
    required String userId,
    required String name,
    String? role,
    String? avatarUrl,
  }) async {
    final row = await _client
        .from('profiles')
        .insert({
          'user_id': userId,
          'name': name,
          'role': role,
          'avatar_url': avatarUrl,
        })
        .select()
        .single();

    return ProfileModel.fromJson(row);
  }

  @override
  Future<void> deleteProfile(String id) async {
    await _client.from('profiles').delete().eq('id', id);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final row = await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .single();

    return ProfileModel.fromJson(row);
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final ext = fileExtension.toLowerCase();
    final contentType = _mimeType(ext);
    final path = '$userId/${DateTime.now().microsecondsSinceEpoch}.$ext';

    await _client.storage.from(_avatarBucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: contentType,
        upsert: true,
      ),
    );

    return _client.storage.from(_avatarBucket).getPublicUrl(path);
  }

  /// Dosya uzantısından MIME türü üretir.
  static String _mimeType(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}
