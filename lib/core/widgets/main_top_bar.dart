import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/core/storage/storage_image.dart';
import 'package:sales_ledger/core/widgets/app_shell.dart';
import 'package:sales_ledger/features/auth/presentation/providers/profile_provider.dart';

/// Ana sekme sayfalarının (Envanter/Satışlar/Alımlar/Finans) üst çubuğu.
/// gereksinim 2.6.3: hamburger menü (sol) + başlık (merkez) + eylemler (sağ).
class MainTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const MainTopBar({super.key, this.title, this.actions = const []});

  /// `null` ise uygulama adı ([AppLocalizations.appTitle]) gösterilir.
  final String? title;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = ref.watch(selectedProfileProvider);
    final isWide = MediaQuery.of(context).size.width >= 1024;

    return Material(
      color: colorScheme.surface,
      elevation: 1,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 4),
              if (!isWide)
                IconButton(
                  icon: const Icon(Icons.menu),
                  color: colorScheme.primary,
                  onPressed: () => mainShellScaffoldKey.currentState?.openDrawer(),
                ),
              Expanded(
                child: Text(
                  title ?? context.l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...actions,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => context.go(AppRoutes.profileSelection),
                  child: Tooltip(
                    message: context.l10n.profileSelectionTitle,
                    child: StorageAvatar(
                      radius: 16,
                      path: profile?.avatarUrl,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      fallback: Text(
                        profile?.name.isNotEmpty == true ? profile!.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
