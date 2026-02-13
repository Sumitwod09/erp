import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/onboarding/screens/industry_selection_screen.dart';
import '../../features/onboarding/screens/onboarding_complete_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/inventory/screens/inventory_list_screen.dart';
import '../../features/accounting/screens/ledger_screen.dart';
import '../../features/sales/screens/sales_list_screen.dart';
import '../../features/settings/screens/module_management_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/module_management_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/module_config_screen.dart';
import '../../features/business/screens/business_profile_screen.dart';
import '../../features/invoices/screens/invoice_list_screen.dart';
import '../layout/main_layout.dart';
import '../../shared/widgets/sidebar/adaptive_sidebar.dart';

/// Application router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<AuthState>(const AuthState());

  // Keep authNotifier in sync with authProvider
  void authListener(AuthState? previous, AuthState next) {
    authNotifier.value = next;
  }

  final subscription = ref.listen(authProvider, authListener);
  ref.onDispose(() => subscription.close());

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.user != null;
      final currentPath = state.matchedLocation;

      // List of public routes that don't require authentication
      final publicRoutes = ['/login', '/signup', '/forgot-password'];
      final isPublicRoute = publicRoutes.contains(currentPath);

      // Redirect to login if not authenticated and trying to access protected route
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      // Redirect to dashboard if authenticated and on login page
      // Also handle root path
      if (isAuthenticated && (currentPath == '/login' || currentPath == '/')) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Onboarding Routes
      GoRoute(
        path: '/onboarding/industry',
        builder: (context, state) => const IndustrySelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/complete',
        builder: (context, state) => const OnboardingCompleteScreen(),
      ),

      // Main App Routes (with layout)
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(
            sidebar: AdaptiveSidebar(
              onNavigate: (route) {
                context.go(route);
              },
            ),
            workspace: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Module Routes (dynamically available based on subscriptions)
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryListScreen(),
          ),
          GoRoute(
            path: '/accounting',
            builder: (context, state) => const LedgerScreen(),
          ),
          GoRoute(
            path: '/sales',
            builder: (context, state) => const SalesListScreen(),
          ),
          GoRoute(
            path: '/invoices',
            builder: (context, state) => const InvoiceListScreen(),
          ),

          // Settings Routes
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/settings/modules',
            builder: (context, state) => const ModuleManagementScreen(),
            routes: [
              GoRoute(
                path: ':moduleId',
                builder: (context, state) {
                  final moduleId = state.pathParameters['moduleId']!;
                  return ModuleConfigScreen(moduleId: moduleId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings/business-profile',
            builder: (context, state) => const BusinessProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
