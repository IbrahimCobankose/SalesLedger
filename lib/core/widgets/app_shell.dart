import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/network/supabase_client.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/core/storage/storage_image.dart';
import 'package:sales_ledger/features/auth/presentation/providers/auth_provider.dart';
import 'package:sales_ledger/features/auth/presentation/providers/profile_provider.dart';

/// Sekme sayfaları kendi içlerinde ayrı bir [Scaffold] kullandığından
/// (FAB için), [MainTopBar]'daki hamburger butonu bu anahtar üzerinden
/// doğrudan dıştaki kabuğun çekmecesini açar.
final mainShellScaffoldKey = GlobalKey<ScaffoldState>();

/// Ana sekmeler (Envanter/Satışlar/Alımlar/Finans) için paylaşılan
/// navigasyon kabuğu (gereksinim 2.6). Genişliğe göre:
/// - < 1024px: alt navigasyon çubuğu + açılır çekmece (hamburger ile).
/// - >= 1024px: sabit yan navigasyon çekmecesi, alt navigasyon gizlenir.
///
/// Form/detay ekranları bu kabuğun route ağacı dışında, üst seviye
/// route olarak `push` edilir; bu sayede alt navigasyon otomatik gizlenir.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabIcons = [
    Icons.inventory_2_outlined,
    Icons.shopping_cart_outlined,
    Icons.local_shipping_outlined,
    Icons.payments_outlined,
  ];
  static const _tabIconsFilled = [
    Icons.inventory_2,
    Icons.shopping_cart,
    Icons.local_shipping,
    Icons.payments,
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tabLabels = [l10n.navInventory, l10n.navSales, l10n.navPurchases, l10n.navFinance];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 280,
                  child: _SideNavigationContent(ref: ref),
                ),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        return Scaffold(
          key: mainShellScaffoldKey,
          drawer: Drawer(child: _SideNavigationContent(ref: ref)),
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(index),
            destinations: [
              for (var i = 0; i < tabLabels.length; i++)
                NavigationDestination(
                  icon: Icon(_tabIcons[i]),
                  selectedIcon: Icon(_tabIconsFilled[i]),
                  label: tabLabels[i],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// gereksinim 2.6.2: profil bilgisi + Profilim/Ayarlar/Excel/Raporlar/Çıkış.
class _SideNavigationContent extends StatelessWidget {
  const _SideNavigationContent({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = ref.watch(selectedProfileProvider);
    final email = supabase.auth.currentUser?.email ?? '';

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StorageAvatar(
                    radius: 24,
                    path: profile?.avatarUrl,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    fallback: Text(
                      profile?.name.isNotEmpty == true ? profile!.name[0].toUpperCase() : '?',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile?.name ?? '',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _DrawerLink(
                icon: Icons.settings_outlined,
                label: context.l10n.navSettings,
                onTap: () {
                  if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
                    Navigator.of(context).pop();
                  }
                  context.push(AppRoutes.settings);
                },
              ),
              const Spacer(),
              _DrawerLink(
                icon: Icons.logout,
                label: context.l10n.navLogout,
                isDestructive: true,
                onTap: () {
                  if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
                    Navigator.of(context).pop();
                  }
                  ref.read(authControllerProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  const _DrawerLink({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.onSurfaceVariant;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
