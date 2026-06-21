import 'package:sales_ledger/features/auth/domain/entities/profile.dart';

/// [Profile] entity'sinin Supabase JSON (de)serileştirme katmanı.
class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.userId,
    required super.name,
    super.role,
    super.avatarUrl,
    required super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      role: json['role'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      userId: profile.userId,
      name: profile.name,
      role: profile.role,
      avatarUrl: profile.avatarUrl,
      createdAt: profile.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'role': role,
      'avatar_url': avatarUrl,
    };
  }
}
