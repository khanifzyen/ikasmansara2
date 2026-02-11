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
import '../../features/donations/presentation/pages/donation_list_page.dart';
import '../../features/news/presentation/pages/news_list_page.dart';
import '../../features/news/presentation/pages/news_detail_page.dart';
import '../../features/forum/presentation/pages/forum_page.dart';
import '../../features/forum/presentation/pages/create_post_page.dart';
import '../../features/forum/presentation/pages/forum_detail_page.dart';
import '../../features/events/presentation/pages/my_tickets_page.dart';
import '../../features/events/presentation/pages/midtrans_payment_page.dart';
import '../../features/events/presentation/pages/event_list_page.dart';
import '../../features/events/presentation/pages/ticket_scanner_page.dart';

// Admin imports
import '../../features/admin/core/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/core/presentation/pages/admin_placeholder_page.dart';
import '../../features/admin/users/presentation/pages/admin_users_page.dart';
import '../../features/admin/users/presentation/pages/admin_user_detail_page.dart';
import '../../features/admin/events/presentation/pages/admin_events_page.dart';
import '../../features/admin/events/presentation/pages/admin_event_detail_page.dart';

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
        builder: (context, state) => SplashPage(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => OnboardingPage(),
      ),

      // Role Selection
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) => RoleSelectionPage(),
      ),

      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginPage(),
      ),

      // Forgot Password
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => ForgotPasswordPage(),
      ),

      // Register Alumni
      GoRoute(
        path: '/register/alumni',
        name: 'register-alumni',
        builder: (context, state) => RegisterAlumniPage(),
      ),

      // Register Public
      GoRoute(
        path: '/register/public',
        name: 'register-public',
        builder: (context, state) => RegisterPublicPage(),
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
                builder: (context, state) => HomePage(),
              ),
            ],
          ),

          // Donasiku
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/donations',
                name: 'donations',
                builder: (context, state) => MyDonationsPage(),
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
                builder: (context, state) => LokerListPage(),
              ),
            ],
          ),
        ],
      ),

      // Event List
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => EventListPage(),
      ),

      // Pages passing through Shell (or separate)
      // Profile (Separate because it comes from Drawer)
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => ProfilePage(),
      ),

      // Directory (Phase 4)
      GoRoute(
        path: '/directory',
        name: 'directory',
        builder: (context, state) => DirectoryPage(),
      ),

      // E-KTA (Phase 4)
      GoRoute(
        path: '/ekta',
        name: 'ekta',
        builder: (context, state) => EKTAPage(),
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
        builder: (context, state) => TicketDetailPage(),
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

      // Donation List (Public)
      GoRoute(
        path: '/donation-list',
        name: 'donation-list',
        builder: (context, state) => DonationListPage(),
      ),

      // My Donations (History)
      GoRoute(
        path: '/my-donations',
        name: 'my-donations',
        builder: (context, state) => MyDonationsPage(),
      ),

      // News List
      GoRoute(
        path: '/news',
        name: 'news',
        builder: (context, state) => NewsListPage(),
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
        builder: (context, state) => ForumPage(),
      ),
      GoRoute(
        path: '/create-post',
        name: 'create-post',
        builder: (context, state) => CreatePostPage(),
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
      GoRoute(
        path: '/ticket-scanner',
        name: 'ticket-scanner',
        builder: (context, state) => TicketScannerPage(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        name: 'admin-dashboard',
        builder: (context, state) => AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        builder: (context, state) => AdminUsersPage(),
      ),
      GoRoute(
        path: '/admin/users/:userId',
        name: 'admin-user-detail',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return AdminUserDetailPage(userId: userId);
        },
      ),
      GoRoute(
        path: '/admin/events',
        name: 'admin-events',
        builder: (context, state) => AdminEventsPage(),
      ),
      GoRoute(
        path: '/admin/events/:eventId',
        name: 'admin-event-detail',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return AdminEventDetailPage(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/admin/donations',
        name: 'admin-donations',
        builder: (context, state) => AdminPlaceholderPage(
          title: 'Kelola Donasi',
          icon: '💰',
          description:
              'Fitur untuk mengelola campaign donasi akan segera hadir.',
        ),
      ),
      GoRoute(
        path: '/admin/news',
        name: 'admin-news',
        builder: (context, state) => AdminPlaceholderPage(
          title: 'Kelola Berita',
          icon: '📰',
          description:
              'Fitur untuk membuat dan mengelola berita akan segera hadir.',
        ),
      ),
      GoRoute(
        path: '/admin/forum',
        name: 'admin-forum',
        builder: (context, state) => AdminPlaceholderPage(
          title: 'Moderasi Forum',
          icon: '💬',
          description:
              'Fitur untuk moderasi post dan komentar forum akan segera hadir.',
        ),
      ),
      GoRoute(
        path: '/admin/loker',
        name: 'admin-loker',
        builder: (context, state) => AdminPlaceholderPage(
          title: 'Approval Loker',
          icon: '💼',
          description: 'Fitur untuk approval lowongan kerja akan segera hadir.',
        ),
      ),
      GoRoute(
        path: '/admin/market',
        name: 'admin-market',
        builder: (context, state) => AdminPlaceholderPage(
          title: 'Approval Market',
          icon: '🛒',
          description:
              'Fitur untuk approval iklan jual-beli akan segera hadir.',
        ),
      ),
      GoRoute(
        path: '/admin/memory',
        name: 'admin-memory',
        builder: (context, state) => AdminPlaceholderPage(
          title: 'Approval Memory',
          icon: '📷',
          description:
              'Fitur untuk approval galeri kenangan akan segera hadir.',
        ),
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
