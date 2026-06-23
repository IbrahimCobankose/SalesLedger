import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/widgets/app_shell.dart';
import 'package:sales_ledger/features/auth/presentation/pages/add_profile_page.dart';
import 'package:sales_ledger/features/auth/presentation/pages/login_page.dart';
import 'package:sales_ledger/features/auth/presentation/pages/profile_selection_page.dart';
import 'package:sales_ledger/features/auth/presentation/pages/email_verification_page.dart';
import 'package:sales_ledger/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:sales_ledger/features/auth/presentation/pages/register_page.dart';
import 'package:sales_ledger/features/auth/presentation/providers/auth_provider.dart';
import 'package:sales_ledger/features/auth/presentation/providers/profile_provider.dart';
import 'package:sales_ledger/features/inventory/presentation/pages/add_product_page.dart';
import 'package:sales_ledger/features/inventory/presentation/pages/inventory_page.dart';
import 'package:sales_ledger/features/inventory/presentation/pages/product_details_page.dart';
import 'package:sales_ledger/features/purchases/presentation/pages/add_purchase_page.dart';
import 'package:sales_ledger/features/purchases/presentation/pages/purchase_details_page.dart';
import 'package:sales_ledger/features/purchases/presentation/pages/purchases_page.dart';
import 'package:sales_ledger/features/finance/presentation/pages/cash_flow_page.dart';
import 'package:sales_ledger/features/finance/presentation/pages/finance_and_stats_page.dart';
import 'package:sales_ledger/features/sales/presentation/pages/add_sale_page.dart';
import 'package:sales_ledger/features/sales/presentation/pages/sale_details_page.dart';
import 'package:sales_ledger/features/sales/presentation/pages/sales_page.dart';
import 'package:sales_ledger/features/settings/presentation/pages/settings_page.dart';

abstract class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const emailVerification = '/email-verification';
  static const forgotPassword = '/forgot-password';
  static const profileSelection = '/profiles';
  static const addProfile = '/profiles/add';
  static const inventory = '/inventory';
  static const sales = '/sales';
  static const purchases = '/purchases';
  static const finance = '/finance';
  static const addProduct = '/products/add';
  static const addPurchase = '/purchases/add';
  static const addSale = '/sales/add';
  static const cashMovements = '/finance/movements';
  static const settings = '/settings';

  static String productDetails(String id) => '/products/$id';
  static String purchaseDetails(String id) => '/purchase-details/$id';
  static String saleDetails(String id) => '/sale-details/$id';
}

/// Tüm route tanımları burada toplanır (gereksinim 2.5). Yetkilendirmeye
/// göre yönlendirme [redirect] callback'i ile merkezi olarak yönetilir:
/// - Oturum yoksa korumalı route'lara erişim engellenir → [AppRoutes.login].
/// - Oturum var ama profil seçilmemişse → [AppRoutes.profileSelection].
///
/// [AppRoutes.addProduct] ve ürün detay route'u, [StatefulShellRoute] dışında
/// üst seviye route olarak tanımlanır; bu sayede `push` edildiklerinde
/// alt navigasyon/yan çekmece otomatik olarak gizlenir (gereksinim 2.6.1).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final session = ref.read(authStateProvider).valueOrNull?.session;
      final isLoggedIn = session != null;
      final hasSelectedProfile = ref.read(selectedProfileProvider) != null;

      final goingToAuthPages = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.emailVerification ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (!isLoggedIn) {
        return goingToAuthPages ? null : AppRoutes.login;
      }

      if (goingToAuthPages) {
        return AppRoutes.profileSelection;
      }

      final goingToProfileFlow = state.matchedLocation == AppRoutes.profileSelection ||
          state.matchedLocation == AppRoutes.addProfile;

      if (!hasSelectedProfile && !goingToProfileFlow) {
        return AppRoutes.profileSelection;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        builder: (context, state) => EmailVerificationPage(
          email: (state.extra as String?) ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.profileSelection,
        builder: (context, state) => const ProfileSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.addProfile,
        builder: (context, state) => const AddProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.addProduct,
        builder: (context, state) => const AddProductPage(),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) => ProductDetailsPage(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.addPurchase,
        builder: (context, state) => const AddPurchasePage(),
      ),
      GoRoute(
        path: '/purchase-details/:id',
        builder: (context, state) => PurchaseDetailsPage(purchaseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.addSale,
        builder: (context, state) => const AddSalePage(),
      ),
      GoRoute(
        path: '/sale-details/:id',
        builder: (context, state) => SaleDetailsPage(saleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.cashMovements,
        builder: (context, state) => const CashFlowPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.inventory, builder: (context, state) => const InventoryPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.sales, builder: (context, state) => const SalesPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.purchases, builder: (context, state) => const PurchasesPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.finance, builder: (context, state) => const FinanceAndStatsPage()),
            ],
          ),
        ],
      ),
    ],
  );
});

/// [authStateProvider] veya [selectedProfileProvider] değiştiğinde
/// GoRouter'ın `redirect` mantığını yeniden tetikler.
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
    ref.listen(selectedProfileProvider, (_, _) => notifyListeners());
  }
}
