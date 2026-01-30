/// Splash Page
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/pb_client.dart';

import 'package:package_info_plus/package_info_plus.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // Fetch package info
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = 'Versi ${packageInfo.version}';
      });
    }

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay for splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is logged in
    final isAuthenticated = PBClient.instance.isAuthenticated;
    if (isAuthenticated) {
      context.go('/home');
      return;
    }

    // Check if onboarding completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted =
        prefs.getBool(AppConstants.onboardingKey) ?? false;

    if (!mounted) return;

    if (!onboardingCompleted) {
      context.go('/onboarding');
    } else {
      context.go('/role-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo-ika.png',
                  width: 350,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Ikatan Alumni SMA Negeri 1 Jepara',
                  style: TextStyle(fontSize: 18, color: AppColors.textGrey),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ),

          // Bottom Version
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: Text(
                  _version,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
