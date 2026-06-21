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
    }
  }

  @override
  Future<Profile> addProfile({
    required String name,
    String? role,
    Uint8List? avatarBytes,
  }) async {
    try {
      final userId = _authDatasource.currentUserId;
      String? avatarUrl;

      if (avatarBytes != null) {
        avatarUrl = await _profileDatasource.uploadAvatar(
          userId: userId,
          bytes: avatarBytes,
          fileExtension: 'jpg',
        );
      }

      return await _profileDatasource.insertProfile(
        userId: userId,
        name: name,
        role: role,
        avatarUrl: avatarUrl,
      );
    } on StorageException {
      throw const AppException('Fotoğraf yüklenemedi. Lütfen tekrar deneyin.');
    } on PostgrestException {
      throw const AppException('Profil kaydedilemedi. Lütfen tekrar deneyin.');
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
  Future<Profile> updateProfile(Profile profile) async {
    try {
      return await _profileDatasource.updateProfile(ProfileModel.fromEntity(profile));
    } on PostgrestException {
      throw const AppException('Profil güncellenemedi. Lütfen tekrar deneyin.');
    }
  }
}
