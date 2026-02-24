import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

/// Reusable list card for admin lists (users, transactions, etc.)
class AdminListCard extends StatelessWidget {
  final String? avatarText;
  final String? avatarEmoji;
  final String? imageUrl;
  final Color? avatarColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? badge;
  final VoidCallback? onTap;

  const AdminListCard({
    super.key,
    this.avatarText,
    this.avatarEmoji,
    this.imageUrl,
    this.avatarColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: avatarColor ?? AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? null
                  : Center(
                      child: avatarEmoji != null
                          ? Text(
                              avatarEmoji!,
                              style: const TextStyle(fontSize: 20),
                            )
                          : Text(
                              avatarText ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Badge or Trailing
            if (badge != null) badge!,
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Status badge for admin lists
class AdminBadge extends StatelessWidget {
  final String text;
  final AdminBadgeType type;

  const AdminBadge({
    super.key,
    required this.text,
    this.type = AdminBadgeType.info,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (type) {
      case AdminBadgeType.success:
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        break;
      case AdminBadgeType.warning:
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        break;
      case AdminBadgeType.error:
        bgColor = AppColors.errorLight;
        textColor = AppColors.error;
        break;
      case AdminBadgeType.info:
        bgColor = AppColors.infoLight;
        textColor = AppColors.info;
        break;
      case AdminBadgeType.grey:
        bgColor = const Color(0xFFF3F4F6);
        textColor = AppColors.textGrey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

enum AdminBadgeType { success, warning, error, info, grey }
