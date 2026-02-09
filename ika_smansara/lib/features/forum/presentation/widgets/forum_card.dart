import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/forum_post.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const ForumCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    // Format date using timeago
    final timeString = timeago.format(post.createdAt, locale: 'id');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Author & Time
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      backgroundImage:
                          (post.authorAvatar != null &&
                              post.authorAvatar!.isNotEmpty)
                          ? CachedNetworkImageProvider(
                              '${AppConstants.pocketBaseUrl}/api/files/users/${post.authorId}/${post.authorAvatar}',
                            )
                          : null,
                      child:
                          (post.authorAvatar == null ||
                              post.authorAvatar!.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                timeString,
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '•',
                                style: TextStyle(color: AppColors.textGrey),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  post.category,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (post.isPinned) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.push_pin,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Content
                Text(
                  post.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

                // Image Attachment (First image only for preview)
                if (post.images.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl:
                          '${AppConstants.pocketBaseUrl}/api/files/forum_posts/${post.id}/${post.images.first}',
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Actions: Like & Comment
                Row(
                  children: [
                    InkWell(
                      onTap: onLike,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              post.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: post.isLiked
                                  ? Colors.red
                                  : AppColors.textGrey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              post.likeCount.toString(),
                              style: TextStyle(
                                fontSize: 13,
                                color: post.isLiked
                                    ? Colors.red
                                    : AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: onComment,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 19,
                              color: AppColors.textGrey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              post.commentCount.toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
