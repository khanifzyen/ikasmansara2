/// Adaptive Breakpoints Helper - Utility functions for responsive layouts
library;

import 'package:flutter/material.dart';
import '../../constants/app_breakpoints.dart';

/// Helper functions for breakpoint-based responsive design
class AdaptiveBreakpoints {
  AdaptiveBreakpoints._();

  /// Check if screen is compact mobile (width < 600)
  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < AppBreakpoints.mediumTablet;
  }

  /// Check if screen is medium tablet (600 <= width < 840)
  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppBreakpoints.mediumTablet &&
        width < AppBreakpoints.expandedDesktop;
  }

  /// Check if screen is expanded desktop (width >= 840)
  static bool isExpanded(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppBreakpoints.expandedDesktop;
  }

  /// Check if screen is mobile or tablet (width < 840)
  static bool isMobileOrTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width < AppBreakpoints.expandedDesktop;
  }

  /// Check if screen is tablet or desktop (width >= 600)
  static bool isTabletOrDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppBreakpoints.mediumTablet;
  }

  /// Get breakpoint label for debugging
  static String getBreakpointLabel(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return 'Expanded (Desktop)';
    } else if (width >= AppBreakpoints.mediumTablet) {
      return 'Medium (Tablet)';
    }
    return 'Compact (Mobile)';
  }

  /// Get adaptive padding based on breakpoint
  static EdgeInsets adaptivePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return const EdgeInsets.all(32);
    } else if (width >= AppBreakpoints.mediumTablet) {
      return const EdgeInsets.all(24);
    }
    return const EdgeInsets.all(16);
  }

  /// Get adaptive spacing based on breakpoint
  static double adaptiveSpacing(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return 32;
    } else if (width >= AppBreakpoints.mediumTablet) {
      return 24;
    }
    return 16;
  }

  /// Get navigation rail width based on breakpoint
  static double navigationRailWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return AppBreakpoints.navRailWidthExpanded;
    }
    return AppBreakpoints.navRailWidthCompact;
  }

  /// Get drawer width based on breakpoint
  static double drawerWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return AppBreakpoints.drawerWidthExpanded;
    }
    return AppBreakpoints.drawerWidthCompact;
  }
}
