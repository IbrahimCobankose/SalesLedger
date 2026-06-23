import 'dart:typed_data';

import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_datasource.dart';
import 'package:sales_ledger/features/auth/data/datasources/profile_datasource.dart';
import 'package:sales_ledger/features/auth/data/models/profile_model.dart';
import 'package:sales_ledger/features/auth/domain/entities/profile.dart';
import 'package:sales_ledger/features/auth/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._profileDatasource, this._authDatasource);

  final ProfileDatasource _profileDatasource;
  final AuthDatasource _authDatasource;

  @override
  Future<List<Profile>> getProfiles() async {
    try {
      return await _profileDatasource.getProfiles(_authDatasource.currentUserId);
    } on PostgrestException {
      throw const AppException('Profiller yüklenemedi. Lütfen tekrar deneyin.');
    } on StateError {
      throw const AppException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
  }

  @override
  Future<Profile> addProfile({
    required String name,
    String? role,
    Uint8List? avatarBytes,
    String? avatarExtension,
  }) async {
    try {
      final userId = _authDatasource.currentUserId;
      String? avatarUrl;

      if (avatarBytes != null) {
        avatarUrl = await _profileDatasource.uploadAvatar(
          userId: userId,
          bytes: avatarBytes,
          fileExtension: avatarExtension ?? 'jpg',
        );
      }

      return await _profileDatasource.insertProfile(
        userId: userId,
        name: name,
        role: role,
        avatarUrl: avatarUrl,
      );
    } on StorageException catch (e) {
      // Bucket bulunamadı veya RLS hatası için daha açıklayıcı mesaj
      final msg = e.message.toLowerCase();
      if (msg.contains('bucket') || msg.contains('not found')) {
        throw const AppException(
          'Fotoğraf yüklenemedi: Depolama alanı yapılandırılmamış. '
          'Supabase Dashboard\'da "avatars" bucket\'ını oluşturun.',
        );
      }
      throw const AppException('Fotoğraf yüklenemedi. Lütfen tekrar deneyin.');
    } on PostgrestException {
      throw const AppException('Profil kaydedilemedi. Lütfen tekrar deneyin.');
    } on StateError {
      throw const AppException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
  }

  @override
  Future<void> deleteProfile(String id) async {
    try {
      await _profileDatasource.deleteProfile(id);
    } on PostgrestException {
      throw const AppException('Profil silinemedi. Lütfen tekrar deneyin.');
    }
  }

  @override
  Future<Profile> updateProfile(
    Profile profile, {
    Uint8List? newAvatarBytes,
    String? avatarExtension,
  }) async {
    try {
      var updated = profile;
      if (newAvatarBytes != null) {
        final avatarUrl = await _profileDatasource.uploadAvatar(
          userId: profile.userId,
          bytes: newAvatarBytes,
          fileExtension: avatarExtension ?? 'jpg',
        );
        updated = profile.copyWith(avatarUrl: avatarUrl);
      }
      return await _profileDatasource.updateProfile(ProfileModel.fromEntity(updated));
    } on StorageException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('bucket') || msg.contains('not found')) {
        throw const AppException(
          'Fotoğraf yüklenemedi: Depolama alanı yapılandırılmamış. '
          'Supabase Dashboard\'da "avatars" bucket\'ını oluşturun.',
        );
      }
      throw const AppException('Fotoğraf yüklenemedi. Lütfen tekrar deneyin.');
    } on PostgrestException {
      throw const AppException('Profil güncellenemedi. Lütfen tekrar deneyin.');
    }
  }
}
