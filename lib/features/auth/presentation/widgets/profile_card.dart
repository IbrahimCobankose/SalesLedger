import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/features/auth/domain/entities/profile.dart';

/// profil_seçimi taslağındaki profil kartı. Fotoğraf yoksa baş harf
/// rozeti gösterilir.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile, required this.onTap});

  final Profile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: colorScheme.surfaceContainerLow,
                backgroundImage:
                    profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                child: profile.avatarUrl == null
                    ? Text(
                        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                        style: textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                profile.name,
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (profile.role != null && profile.role!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    profile.role!,
                    style: textTheme.labelSmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// profil_seçimi taslağındaki "Yeni Profil Ekle" kesikli çizgili kart.
class AddProfileCard extends StatelessWidget {
  const AddProfileCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant, style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: colorScheme.surfaceContainer,
                child: Icon(Icons.add, size: 32, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.profileSelectionAddNew,
                style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.profileSelectionAddNewSubtitle,
                style: textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
