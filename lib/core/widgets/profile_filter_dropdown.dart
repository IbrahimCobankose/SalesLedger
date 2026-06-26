import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/features/auth/presentation/providers/profile_provider.dart';

/// Envanter/alım/satış modüllerinde ortak kullanılan profil filtre seçici.
/// Aktif kullanıcının profillerini yükler ve "Tüm Profiller" + her profil
/// seçeneğini sunar. Yalnızca birden fazla profil varsa görünür (tek profilde
/// filtrelemenin anlamı yok).
class ProfileFilterDropdown extends ConsumerWidget {
  const ProfileFilterDropdown({
    super.key,
    required this.selectedProfileId,
    required this.onChanged,
  });

  final String? selectedProfileId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final profiles = ref.watch(profilesProvider).valueOrNull ?? const [];

    if (profiles.length < 2) return const SizedBox.shrink();

    var selectedName = l10n.commonAllProfiles;
    if (selectedProfileId != null) {
      for (final profile in profiles) {
        if (profile.id == selectedProfileId) {
          selectedName = profile.name;
          break;
        }
      }
    }

    return PopupMenuButton<String?>(
      tooltip: l10n.commonProfile,
      initialValue: selectedProfileId,
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem<String?>(value: null, child: Text(l10n.commonAllProfiles)),
        for (final profile in profiles)
          PopupMenuItem<String?>(value: profile.id, child: Text(profile.name)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              selectedName,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            Icon(Icons.arrow_drop_down, size: 18, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
