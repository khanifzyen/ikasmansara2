/// App Sizes - Layout size constraints
library;

import 'package:flutter/widgets.dart';
import 'app_breakpoints.dart';

/// Layout size constraints for responsive design
class AppSizes {
  AppSizes._();

  /// Horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return 32;
    } else if (width >= AppBreakpoints.mediumTablet) {
      return 24;
    }
    return 16;
  }

  /// Vertical padding based on screen size
  static double verticalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return 32;
    } else if (width >= AppBreakpoints.mediumTablet) {
      return 24;
    }
    return 16;
  }

  /// Safe area horizontal padding
  static double safePaddingHorizontal(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return 24;
    }
    return 16;
  }

  /// Content max width with center alignment
  static double maxWidthForContent(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.maxContentWidth) {
      return AppBreakpoints.maxContentWidth;
    }
    return width;
  }

  /// Form max width for optimal usability
  static double maxWidthForForm(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.maxFormWidth) {
      return AppBreakpoints.maxFormWidth;
    }
    return width - (horizontalPadding(context) * 2);
  }

  /// Grid max cross axis extent based on screen size
  static double gridMaxExtent(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return 350;
    } else if (width >= AppBreakpoints.mediumTablet) {
      return 300;
    }
    return 280;
  }

  /// Avatar size based on screen size
  static double avatarSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return 64;
    }
    return 48;
  }

  /// Icon size based on screen size
  static double iconSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return 24;
    }
    return 20;
  }
}
