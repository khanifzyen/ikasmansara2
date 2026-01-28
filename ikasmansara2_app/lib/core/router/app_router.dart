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
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/main_shell.dart';

import '../../features/loker/presentation/pages/loker_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/directory/presentation/pages/directory_page.dart';
import '../../features/ekta/presentation/pages/ekta_page.dart';
import '../../features/events/presentation/pages/event_detail_page.dart';
import '../../features/events/presentation/pages/ticket_detail_page.dart';
import '../../features/donations/presentation/pages/donation_detail_page.dart';
import '../../features/donations/presentation/pages/my_donations_page.dart';
import '../../features/news/presentation/pages/news_list_page.dart';
import '../../features/news/presentation/pages/news_detail_page.dart';
import '../../features/forum/presentation/pages/forum_page.dart';
import '../../features/forum/presentation/pages/create_post_page.dart';
import '../../features/forum/presentation/pages/forum_detail_page.dart';
import '../../features/events/presentation/pages/my_tickets_page.dart';
import '../../features/events/presentation/pages/midtrans_payment_page.dart';

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

      // Forgot Password
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
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

      // Main Shell (Bottom Nav)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // Donasiku
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/donations',
                name: 'donations',
                builder: (context, state) => const MyDonationsPage(),
              ),
            ],
          ),

          // Tiketku
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tickets',
                name: 'tickets',
                builder: (context, state) {
                  final userId =
                      PBClient.instance.pb.authStore.record?.id ?? '';
                  return MyTicketsPage(userId: userId);
                },
              ),
            ],
          ),

          // Loker
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/loker',
                name: 'loker',
                builder: (context, state) => const LokerListPage(),
              ),
            ],
          ),
        ],
      ),

      // Pages passing through Shell (or separate)
      // Profile (Separate because it comes from Drawer)
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),

      // Directory (Phase 4)
      GoRoute(
        path: '/directory',
        name: 'directory',
        builder: (context, state) => const DirectoryPage(),
      ),

      // E-KTA (Phase 4)
      GoRoute(
        path: '/ekta',
        name: 'ekta',
        builder: (context, state) => const EKTAPage(),
      ),

      // Event Detail (Phase 5)
      GoRoute(
        path: '/event-detail',
        name: 'event-detail',
        builder: (context, state) {
          final eventId = state.extra as String;
          return EventDetailPage(eventId: eventId);
        },
      ),

      // Ticket Detail (Phase 5)
      GoRoute(
        path: '/ticket-detail',
        name: 'ticket-detail',
        builder: (context, state) => const TicketDetailPage(),
      ),

      // Donation Detail (Phase 6)
      GoRoute(
        path: '/donation-detail',
        name: 'donation-detail',
        builder: (context, state) {
          final donationId = state.extra as String;
          return DonationDetailPage(donationId: donationId);
        },
      ),

      // My Donations (History)
      GoRoute(
        path: '/my-donations',
        name: 'my-donations',
        builder: (context, state) => const MyDonationsPage(),
      ),

      // News List
      GoRoute(
        path: '/news',
        name: 'news',
        builder: (context, state) => const NewsListPage(),
      ),

      // News Detail
      GoRoute(
        path: '/news-detail',
        name: 'news-detail',
        builder: (context, state) {
          final newsId = state.extra as String;
          return NewsDetailPage(newsId: newsId);
        },
      ),

      // Forum Routes
      GoRoute(
        path: '/forum',
        name: 'forum',
        builder: (context, state) => const ForumPage(),
      ),
      GoRoute(
        path: '/create-post',
        name: 'create-post',
        builder: (context, state) => const CreatePostPage(),
      ),
      GoRoute(
        path: '/forum-detail',
        name: 'forum-detail',
        builder: (context, state) {
          final postId = state.extra as String;
          return ForumDetailPage(postId: postId);
        },
      ),
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return MidtransPaymentPage(
            paymentUrl: extras['paymentUrl'] as String,
            bookingId: extras['bookingId'] as String,
            fromEventDetail: extras['fromEventDetail'] as bool? ?? false,
          );
        },
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
        state.matchedLocation == '/forgot-password' ||
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
