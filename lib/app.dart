import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/core/theme/app_theme.dart';
import 'package:sales_ledger/features/auth/presentation/pages/login_page.dart';
import 'package:sales_ledger/features/auth/presentation/pages/profile_selection_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Satış Defteri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // Cihaz tercihine göre otomatik
      home: const _AuthGate(),
    );
  }
}

/// Supabase oturum durumunu dinler ve kullanıcıyı doğru sayfaya yönlendirir.
///
/// Akış:
/// - Oturum yok  → [LoginPage]
/// - Oturum var  → [ProfileSelectionPage]
///
/// [onAuthStateChange] stream'i her session değişiminde (giriş, çıkış,
/// token yenileme) tetiklenir; bu sayede elle navigate yazmak gerekmez.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Stream henüz bağlanmadıysa — splash benzeri yükleme ekranı
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final session = snapshot.data?.session;

        if (session != null) {
          // Oturum açık → profil seçimine git
          return const ProfileSelectionPage();
        }

        // Oturum yok → giriş sayfasına git
        return const LoginPage();
      },
    );
  }
}

/// Uygulama ilk açılırken Supabase oturum kontrolü yapılırken
/// gösterilen minimal yükleme ekranı.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Satış Defteri',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}