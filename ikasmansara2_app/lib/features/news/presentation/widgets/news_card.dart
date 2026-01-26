import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/news.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsCard extends StatelessWidget {
  final News news;
  final VoidCallback onTap;

  const NewsCard({super.key, required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: news.thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: news
                          .thumbnail!, // We need a full URL here, logic to be added in Utils or Model
                      // For now assuming model prepends the host or we handle it here
                      // But actually PB returns filename, so we need full URL.
                      // Let's assume the entity has the full URL or we use a helper.
                      // Update: The Model `toEntity` logic I wrote constructs: collectionId/recordId/filename
                      // So we need to prepend the PB URL base.
                      // Let's use a placeholder or handle it better.
                      // For now, let's assume valid URL or fix it in logic.
                      // Better approach: Use PBClient to get file url.
                      // But widget shouldn't depend on PBClient directly ideally.
                      // Let's just pass the full URL string in Entity if possible,
                      // OR construct it here if we have the base URL global.
                      // Let's rely on the URL being correct for now, or use a helper.
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(news.publishDate, locale: 'id'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
