import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikasmansara_app/common_widgets/cards/post_card.dart';
import 'package:ikasmansara_app/common_widgets/layout/empty_state.dart';
import 'package:ikasmansara_app/common_widgets/layout/filter_chips.dart';
import 'package:ikasmansara_app/common_widgets/layout/loading_shimmer.dart';
import 'package:ikasmansara_app/core/theme/app_colors.dart';
import 'package:ikasmansara_app/features/forum/presentation/forum_controller.dart';

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  final List<String> _categories = [
    'Semua',
    'Umum',
    'Karir',
    'Event',
    'Diskusi',
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final forumState = ref.watch(forumControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Forum Alumni'), centerTitle: true),
      body: Column(
        children: [
          FilterChips(
            items: _categories,
            selectedIndex: _selectedIndex,
            onSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
              ref
                  .read(forumControllerProvider.notifier)
                  .filterByCategory(_categories[index]);
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(forumControllerProvider.notifier)
                  .refresh(category: _categories[_selectedIndex]),
              child: forumState.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const EmptyState(
                      title: 'Belum Ada Postingan',
                      message: 'Jadilah yang pertama untuk membagikan sesuatu!',
                      icon: Icons.forum_outlined,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return PostCard(
                        post: posts[index],
                        onTap: () {
                          context.push(
                            '/forum/${posts[index].id}',
                            extra: posts[index],
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => LoadingShimmer.list(),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/forum/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
