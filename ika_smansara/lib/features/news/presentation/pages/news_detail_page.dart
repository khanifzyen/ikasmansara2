import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/news.dart';
import '../../domain/usecases/get_news_detail.dart';

class NewsDetailPage extends StatelessWidget {
  final String newsId; // Should be passed from router

  const NewsDetailPage({super.key, required this.newsId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<News>(
      future: GetIt.I<GetNewsDetail>().call(newsId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('News not found')));
        }

        final news = snapshot.data!;
        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              // AppBar with Hero Image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: Colors.white,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => context.pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: news.thumbnail != null
                      ? CachedNetworkImage(
                          imageUrl: news.thumbnail!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/placeholder_news.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/placeholder_news.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date & Category
                      Row(
                        children: [
                          Text(
                            DateFormat(
                              'EEEE, d MMMM yyyy',
                              'id',
                            ).format(news.publishDate),
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                          SizedBox(width: 8),
                          Text(
                            news.category.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Title
                      Text(
                        news.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Author
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: news.authorAvatar != null
                                ? CachedNetworkImageProvider(news.authorAvatar!)
                                : null,
                            child: news.authorAvatar == null
                                ? Icon(Icons.person, size: 16)
                                : null,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.authorName ?? 'Admin',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Penulis',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      const Divider(),
                      SizedBox(height: 16),

                      // Content
                      Html(
                        data: news.content,
                        style: {
                          "body": Style(
                            fontSize: FontSize(16),
                            lineHeight: LineHeight(1.6),
                            color: AppColors.textDark,
                            margin: Margins
                                .zero, // Replaces margin: EdgeInsets.zero
                          ),
                          "p": Style(margin: Margins.only(bottom: 16)),
                          "img": Style(
                            width: Width(100, Unit.percent),
                            height: Height.auto(),
                            margin: Margins.symmetric(vertical: 10),
                          ),
                        },
                      ),

                      SizedBox(height: 30),

                      // Share Button
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement share
                          },
                          icon: Icon(Icons.share, size: 18),
                          label: Text('Bagikan Berita'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textDark,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
