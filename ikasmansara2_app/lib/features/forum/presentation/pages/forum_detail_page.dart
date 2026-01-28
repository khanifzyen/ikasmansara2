import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ForumDetailPage extends StatelessWidget {
  final String postId;

  const ForumDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Diskusi'),
        foregroundColor: AppColors.textDark,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(child: Text('Detail Post & Komentar (Coming Soon)')),
    );
  }
}
