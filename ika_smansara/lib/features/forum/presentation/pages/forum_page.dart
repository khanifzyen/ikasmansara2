import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/adaptive/adaptive_breakpoints.dart';
import '../../../../core/widgets/adaptive/adaptive_container.dart';
import '../../presentation/bloc/forum_bloc.dart';
import '../../presentation/widgets/forum_card.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ForumBloc>()..add(const FetchForumPosts()),
      child: const ForumView(),
    );
  }
}

class ForumView extends StatefulWidget {
  const ForumView({super.key});

  @override
  State<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView> {
  final List<String> _categories = [
    'Semua',
    'Karir',
    'Nostalgia',
    'Bisnis',
    'Umum',
    'Event',
  ];
  String _selectedCategory = 'Semua';

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
    });
    context.read<ForumBloc>().add(
      FetchForumPosts(category: category == 'Semua' ? null : category),
    );
  }

  Future<void> _onRefresh() async {
    context.read<ForumBloc>().add(
      RefreshForumPosts(
        category: _selectedCategory == 'Semua' ? null : _selectedCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forum Diskusi',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Category Selector
          Container(
            height: 60,
            color: Theme.of(context).colorScheme.surface,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: AdaptiveBreakpoints.adaptivePadding(context).left,
                vertical: 12,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => SizedBox(
                width: AdaptiveBreakpoints.adaptiveSpacing(context) / 2,
              ),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return InkWell(
                  onTap: () => _onCategorySelected(category),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AdaptiveBreakpoints.adaptivePadding(
                        context,
                      ).left,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Post List
          Expanded(
            child: BlocBuilder<ForumBloc, ForumState>(
              builder: (context, state) {
                if (state is ForumLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ForumError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        TextButton(
                          onPressed: _onRefresh,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                } else if (state is ForumLoaded) {
                  if (state.posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada postingan di kategori ini',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: AdaptiveContainer(
                      widthType: AdaptiveWidthType.content,
                      child: ListView.builder(
                        padding: AdaptiveBreakpoints.adaptivePadding(context),
                        itemCount: state.posts.length,
                        itemBuilder: (context, index) {
                          final post = state.posts[index];
                          return ForumCard(
                            post: post,
                            onTap: () {
                              // Go to detail
                              context.push('/forum-detail', extra: post.id);
                            },
                            onLike: () {
                              context.read<ForumBloc>().add(
                                LikePostEvent(post.id),
                              );
                            },
                            onComment: () {
                              context.push('/forum-detail', extra: post.id);
                            },
                          );
                        },
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-post');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
