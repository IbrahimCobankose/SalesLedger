import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/gen/app_localizations.dart';
import 'package:sales_ledger/core/l10n/locale_provider.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/core/theme/app_theme.dart';

/// Uygulamanın kökü. Navigasyon yalnızca [GoRouter] ile yapılır
/// (gereksinim 2.5); `Navigator.push`/`MaterialPageRoute` kullanılmaz.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Satış Defteri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
