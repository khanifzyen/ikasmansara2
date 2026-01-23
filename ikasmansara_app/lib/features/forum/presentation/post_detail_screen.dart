import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikasmansara_app/common_widgets/inputs/custom_text_field.dart';
import 'package:ikasmansara_app/core/theme/app_colors.dart';
import 'package:ikasmansara_app/core/theme/app_text_styles.dart';
import 'package:ikasmansara_app/core/utils/formatters.dart';
import 'package:ikasmansara_app/features/forum/domain/entities/post_entity.dart';
import 'package:ikasmansara_app/features/forum/domain/usecases/add_comment.dart';
import 'package:ikasmansara_app/features/forum/presentation/providers/forum_providers.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostEntity post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final AddComment addComment = ref.read(addCommentProvider);
      await addComment(postId: widget.post.id, content: content);

      _commentController.clear();
      // Refresh comments
      ref.invalidate(getPostCommentsProvider(widget.post.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengirim komentar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch comments for this post
    final commentsAsync = ref.watch(getPostCommentsProvider(widget.post.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Postingan')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Original Post Content ---
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            (widget.post.author?.avatarUrl != null &&
                                widget.post.author!.avatarUrl!.isNotEmpty)
                            ? CachedNetworkImageProvider(
                                widget.post.author!.avatarUrl!,
                              )
                            : null,
                        child:
                            (widget.post.author?.avatarUrl == null ||
                                widget.post.author!.avatarUrl!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.author?.name ?? 'Pengguna',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            Formatters.date(widget.post.createdAt),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.post.content, style: AppTextStyles.bodyMedium),

                  if (widget.post.images.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.post.images.first,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (_, _, _) => const SizedBox(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  Text('Komentar', style: AppTextStyles.h4),
                  const SizedBox(height: 16),

                  // --- Comments List ---
                  commentsAsync.when(
                    data: (comments) {
                      if (comments.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'Belum ada komentar.\nJadilah yang pertama!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage:
                                    (comment.author?.avatarUrl != null &&
                                        comment.author!.avatarUrl!.isNotEmpty)
                                    ? CachedNetworkImageProvider(
                                        comment.author!.avatarUrl!,
                                      )
                                    : null,
                                child:
                                    (comment.author?.avatarUrl == null ||
                                        comment.author!.avatarUrl!.isEmpty)
                                    ? const Icon(Icons.person, size: 16)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            comment.author?.name ?? 'Pengguna',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            Formatters.date(
                                              comment.createdAt,
                                            ), // Short date format preferred
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment.content,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Gagal memuat komentar: $e'),
                  ),
                  const SizedBox(height: 80), // Space for bottom input
                ],
              ),
            ),
          ),

          // --- Bottom Comment Input ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _commentController,
                    hint: 'Tulis komentar...',
                    // Removed maxLines to default to 1 for input field feel
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _isSending ? null : _sendComment,
                  icon: _isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
