import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatelessWidget {
  final String userName;
  final String? userAvatar;
  final String date; // e.g. "2 jam yang lalu"
  final String content;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.userName,
    this.userAvatar,
    required this.date,
    required this.content,
    this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    this.isLiked = false,
    required this.onLike,
    required this.onComment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: userAvatar != null
                        ? CachedNetworkImageProvider(userAvatar!)
                        : null,
                    radius: 20,
                    child: userAvatar == null ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(date, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Content
              Text(content, style: AppTextStyles.bodyMedium),
              if (imageUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Actions
              Row(
                children: [
                  _ActionButton(
                    icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    label: '$likeCount',
                    color: isLiked ? AppColors.primary : AppColors.textGrey,
                    onTap: onLike,
                  ),
                  const SizedBox(width: 24),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '$commentCount',
                    color: AppColors.textGrey,
                    onTap: onComment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
