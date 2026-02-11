/// App Breakpoints - Material Design 3 breakpoints
library;

/// Breakpoint constants following Material Design 3 guidelines
class AppBreakpoints {
  AppBreakpoints._();

  /// Compact mobile: width < 600
  static const double compactMobile = 0;

  /// Medium tablet: 600 <= width < 840
  static const double mediumTablet = 600;

  /// Expanded desktop: width >= 840
  static const double expandedDesktop = 840;

  /// Maximum content width for readability on large screens
  static const double maxContentWidth = 1200;

  /// Maximum form width for optimal usability
  static const double maxFormWidth = 600;

  /// Maximum card width for consistent layouts
  static const double maxCardWidth = 400;

  /// Navigation rail width for compact (mobile/tablet)
  static const double navRailWidthCompact = 56;

  /// Navigation rail width for expanded (desktop)
  static const double navRailWidthExpanded = 80;

  /// Drawer width for mobile/tablet
  static const double drawerWidthCompact = 280;

  /// Drawer width for desktop
  static const double drawerWidthExpanded = 320;
}
