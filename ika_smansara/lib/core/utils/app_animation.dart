/// Animation constants and utilities
library;

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppAnimations {
  const AppAnimations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve sharpCurve = Curves.easeOut;

  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration listStaggerDelay = Duration(milliseconds: 75);
}

class AppLoadingIndicator {
  const AppLoadingIndicator._();

  static const primary = AlwaysStoppedAnimation<Color>(AppColors.primary);
  static const white = AlwaysStoppedAnimation<Color>(Colors.white);
  static const grey = AlwaysStoppedAnimation<Color>(Colors.grey);
}
