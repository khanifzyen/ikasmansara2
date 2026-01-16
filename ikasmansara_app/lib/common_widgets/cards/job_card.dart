import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String jobType; // Fulltime, Remote, etc.
  final String datePosted;
  final String? companyLogo;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.title,
    required this.company,
    required this.location,
    required this.jobType,
    required this.datePosted,
    this.companyLogo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      image: companyLogo != null
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(companyLogo!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: companyLogo == null
                        ? Center(
                            child: Text(
                              company[0].toUpperCase(),
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Header Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.h4),
                        const SizedBox(height: 4),
                        Text(
                          company,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bookmark Icon (optional) can be added here
                ],
              ),
              const SizedBox(height: 12),
              // Tags
              Row(
                children: [
                  _buildTag(location, Icons.location_on_outlined),
                  const SizedBox(width: 8),
                  _buildTag(jobType, Icons.work_outline),
                ],
              ),
              const SizedBox(height: 12),
              // Footer
              Text('Posted $datePosted', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textGrey),
          const SizedBox(width: 4),
          Text(text, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
