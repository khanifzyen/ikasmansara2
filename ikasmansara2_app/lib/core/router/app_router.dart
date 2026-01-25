/// App Router with GoRouter
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../network/pb_client.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/register_alumni_page.dart';
import '../../features/auth/presentation/pages/register_public_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    routes: [
      // Splash
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Role Selection
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionPage(),
      ),

      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Register Alumni
      GoRoute(
        path: '/register/alumni',
        name: 'register-alumni',
        builder: (context, state) => const RegisterAlumniPage(),
      ),

      // Register Public
      GoRoute(
        path: '/register/public',
        name: 'register-public',
        builder: (context, state) => const RegisterPublicPage(),
      ),

      // Home (Main Shell)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const Placeholder(), // TODO: ProfilePage
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );

  /// Handle authentication redirects
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = PBClient.instance.isAuthenticated;
    final isAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register/alumni' ||
        state.matchedLocation == '/register/public' ||
        state.matchedLocation == '/role-selection' ||
        state.matchedLocation == '/onboarding' ||
        state.matchedLocation == '/';

    // If logged in and trying to access auth routes, go to home
    if (isLoggedIn && isAuthRoute && state.matchedLocation != '/') {
      return '/home';
    }

    // If not logged in and trying to access protected routes
    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    return null;
  }
}
