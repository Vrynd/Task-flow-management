import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/navigation/presentation/screens/main_navigation_screen.dart';

/// [AppRouter] mendefinisikan sistem routing terpusat menggunakan [GoRouter].
abstract class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String settings = '/settings';

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: splash,
      refreshListenable: authProvider,
      redirect: _buildRedirect(authProvider),
      routes: [
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (_, __) => const _SplashScreen(),
        ),
        GoRoute(
          path: login,
          name: 'login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          name: 'register',
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: home,
          name: 'home',
          builder: (_, __) => const MainNavigationScreen(),
        ),
        GoRoute(
          path: settings,
          name: 'settings',
          builder: (_, __) => const SettingsScreen(),
        ),
      ],
    );
  }

  static GoRouterRedirect _buildRedirect(AuthProvider authProvider) {
    return (context, state) {
      final status = authProvider.status;
      final location = state.matchedLocation;

      if (status == AuthStatus.initial) {
        return location == splash ? null : splash;
      }

      final isAuth = authProvider.isAuthenticated;
      final isOnAuthPage = location == login || location == register;
      final isOnSplash = location == splash;

      if (isAuth && (isOnAuthPage || isOnSplash)) return home;
      if (!isAuth && !isOnAuthPage) return login;

      return null;
    };
  }
}

// ─── Splash Screen ────────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
