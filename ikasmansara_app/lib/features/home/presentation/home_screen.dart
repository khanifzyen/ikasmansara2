import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'widgets/home_header.dart';
import 'widgets/home_action_menu.dart';
import 'widgets/home_campaign_slider.dart';
import 'widgets/home_news_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HomeHeader(),
              SizedBox(height: 32),
              HomeActionMenu(),
              SizedBox(height: 32),
              HomeCampaignSlider(),
              SizedBox(height: 32),
              HomeNewsSection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
