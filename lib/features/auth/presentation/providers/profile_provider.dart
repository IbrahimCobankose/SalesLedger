import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_ledger/core/network/supabase_client.dart';
import 'package:sales_ledger/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:sales_ledger/features/auth/data/datasources/profile_supabase_datasource.dart';
import 'package:sales_ledger/features/auth/data/repositories/profile_repository_impl.dart';
import 'package:sales_ledger/features/auth/domain/entities/profile.dart';
import 'package:sales_ledger/features/auth/domain/repositories/profile_repository.dart';
import 'package:sales_ledger/features/auth/domain/usecases/add_profile_usecase.dart';
import 'package:sales_ledger/features/auth/domain/usecases/get_profiles_usecase.dart';

/// Supabase kullanıcı meta verisinden şirket adını okur.
String? _pendingCompanyName() {
  return supabase.auth.currentUser?.userMetadata?['company_name'] as String?;
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ProfileSupabaseDatasource(supabase),
    AuthSupabaseDatasource(supabase),
  );
});

final getProfilesUseCaseProvider = Provider(
  (ref) => GetProfilesUseCase(ref.watch(profileRepositoryProvider)),
);

final addProfileUseCaseProvider = Provider(
  (ref) => AddProfileUseCase(ref.watch(profileRepositoryProvider)),
);

/// Aktif hesaba bağlı profil listesini getirir ve önbelleğe alır.
/// `autoDispose`, profil seçim ekranından çıkıldığında belleği serbest bırakır.
class ProfilesNotifier extends AutoDisposeAsyncNotifier<List<Profile>> {
  @override
  Future<List<Profile>> build() async {
    final profiles = await ref.read(getProfilesUseCaseProvider)();

    // İlk girişte (e-posta doğrulama sonrası) profil listesi boşsa
    // kayıt sırasında meta veriye kaydedilen şirket adından otomatik profil oluştur.
    // Bu otomatik oluşturma başarısız olursa (örn. ağ/RLS sorunu) tüm ekranın
    // hataya düşüp kullanıcıyı kilitlememesi için hatayı yutuyor ve kullanıcının
    // "Yeni Profil Ekle" ile manuel denemesine izin veriyoruz.
    if (profiles.isEmpty) {
      final companyName = _pendingCompanyName();
      if (companyName != null && companyName.trim().isNotEmpty) {
        try {
          final firstProfile = await ref.read(addProfileUseCaseProvider)(
            name: companyName.trim(),
          );
          return [firstProfile];
        } catch (_) {
          return profiles;
        }
      }
    }

    return profiles;
  }

  Future<void> addProfile({
    required String name,
    String? role,
    Uint8List? avatarBytes,
    String? avatarExtension,
  }) async {
    final newProfile = await ref.read(addProfileUseCaseProvider)(
      name: name,
      role: role,
      avatarBytes: avatarBytes,
      avatarExtension: avatarExtension,
    );

    final current = state.valueOrNull ?? const [];
    state = AsyncData([...current, newProfile]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(getProfilesUseCaseProvider)());
  }
}

final profilesProvider =
    AutoDisposeAsyncNotifierProvider<ProfilesNotifier, List<Profile>>(
  ProfilesNotifier.new,
);

/// Oturum boyunca seçilen aktif profili tutar. Profil seçim ekranından
/// çıkana kadar (giriş yapılmış oturum süresince) canlı tutulur, bu yüzden
/// `autoDispose` kullanılmaz.
class SelectedProfileNotifier extends Notifier<Profile?> {
  @override
  Profile? build() => null;

  void select(Profile profile) => state = profile;

  void clear() => state = null;
}

final selectedProfileProvider =
    NotifierProvider<SelectedProfileNotifier, Profile?>(
  SelectedProfileNotifier.new,
);
