import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboard/presentation/splash_screen.dart';
import '../../features/onboard/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/directory/presentation/directory_screen.dart';
import '../../features/marketplace/presentation/market_screen.dart';
import '../../features/marketplace/presentation/add_product_screen.dart';
import '../../features/marketplace/presentation/product_detail_screen.dart';
import '../../features/loker/presentation/loker_screen.dart';
import '../../features/loker/presentation/job_detail_screen.dart';
import '../../features/loker/presentation/post_job_screen.dart';

import '../../features/donation/presentation/donation_screen.dart';
import '../../features/donation/presentation/campaign_detail_screen.dart';
import '../../features/forum/domain/entities/post_entity.dart';
import '../../features/forum/presentation/create_post_screen.dart';
import '../../features/forum/presentation/forum_screen.dart';
import '../../features/forum/presentation/post_detail_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/ekta_screen.dart';
import 'scaffold_with_nav_bar.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // NO-SHELL ROUTES (Splash, Auth, Onboard)
      GoRoute(
        path: '/splash',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // SHELL ROUTES (Bottom Nav)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // 1: Directory
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/directory',
                builder: (context, state) => const DirectoryScreen(),
              ),
            ],
          ),
          // 2: Donation
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/donation',
                builder: (context, state) => const DonationScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return CampaignDetailScreen(campaignId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // 3: Loker
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/loker',
                builder: (context, state) => const LokerScreen(),
                routes: [
                  GoRoute(
                    path: 'post',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const PostJobScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return JobDetailScreen(jobId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // 4: Lainnya (Menu) - Dummy route, intercepted by ScaffoldWithNavBar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                builder: (context, state) => const SizedBox(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/market',
        name: 'market',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MarketScreen(),
        routes: [
          GoRoute(
            path: 'add',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const AddProductScreen(),
          ),
          GoRoute(
            path: ':id',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ProductDetailScreen(productId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/forum',
        name: 'forum',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ForumScreen(),
        routes: [
          GoRoute(
            path: 'create',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const CreatePostScreen(),
          ),
          GoRoute(
            path: ':id',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              // final id = state.pathParameters['id']!;
              final extra = state.extra as PostEntity?;
              // Retrieve from extra if available (optimistic), else fetch (handled in screen if needed)
              // Currently Screen requires PostEntity. If deep linking, we might need to fetch first.
              // For now, let's assume we always pass extra from list,
              // or handle null in screen (PostDetailScreen currently requires 'post' object).
              // We should update PostDetailScreen to fetch by ID if post is null?
              // Or just fetch detail in screen using ID.
              // The implementation of PostDetailScreen takes 'post' object.
              // Let's rely on 'extra' for now, or fallback to fetching if I update screen logic.
              if (extra != null) {
                return PostDetailScreen(post: extra);
              }
              // Fallback or Error page if no object passed
              // Ideally we'd have a loading wrapper that fetches by ID.
              // For MVP let's return error or handle it.
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text(
                    'Objek post tidak ditemukan. Navigasi harus dari list.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/ekta',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EKTAScreen(),
      ),
    ],
  );
}
