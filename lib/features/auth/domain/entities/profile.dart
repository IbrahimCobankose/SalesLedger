/// Bir hesaba bağlı, saf (Flutter/Supabase bağımsız) profil varlığı.
///
/// [profiles] tablosunun domain karşılığıdır. Değişmezdir (immutable);
/// güncelleme [copyWith] ile yeni bir örnek üretilerek yapılır.
class Profile {
  const Profile({
    required this.id,
    required this.userId,
    required this.name,
    this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final String? role;
  final String? avatarUrl;
  final DateTime createdAt;

  Profile copyWith({
    String? name,
    String? role,
    String? avatarUrl,
  }) {
    return Profile(
      id: id,
      userId: userId,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }
}
