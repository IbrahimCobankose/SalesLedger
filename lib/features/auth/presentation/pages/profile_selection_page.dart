import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/auth/presentation/providers/auth_provider.dart';
import 'package:sales_ledger/features/auth/presentation/providers/profile_provider.dart';
import 'package:sales_ledger/features/auth/presentation/widgets/profile_card.dart';

/// profil_seçimi.html taslağına karşılık gelen profil seçim ekranı.
/// Oturum açık olan hesaba bağlı tüm profilleri kartlı bir ızgarada listeler.
class ProfileSelectionPage extends ConsumerWidget {
  const ProfileSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final profilesAsync = ref.watch(profilesProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.navLogout,
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.menu_book, color: colorScheme.onPrimaryContainer, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.profileSelectionTitle, style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 8),
                  Text(
                    l10n.profileSelectionSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  profilesAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, _) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        CustomSnackbar.show(
                          context,
                          message: l10n.profileSelectionLoadFailed,
                          isError: true,
                        );
                      });
                      return const SizedBox.shrink();
                    },
                    data: (profiles) => GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.82,
                      children: [
                        ...profiles.map(
                          (profile) => ProfileCard(
                            profile: profile,
                            onTap: () {
                              ref.read(selectedProfileProvider.notifier).select(profile);
                              context.go(AppRoutes.inventory);
                            },
                          ),
                        ),
                        AddProfileCard(
                          onTap: () => context.push(AppRoutes.addProfile),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
