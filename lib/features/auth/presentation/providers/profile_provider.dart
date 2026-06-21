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
  Future<List<Profile>> build() {
    return ref.read(getProfilesUseCaseProvider)();
  }

  Future<void> addProfile({
    required String name,
    String? role,
    Uint8List? avatarBytes,
  }) async {
    final newProfile = await ref.read(addProfileUseCaseProvider)(
      name: name,
      role: role,
      avatarBytes: avatarBytes,
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
