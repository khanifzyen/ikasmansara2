# Adaptive UI Documentation - IKA SMANSARA

## Overview

IKA SMANSARA app now uses a comprehensive adaptive UI system that follows Material Design 3 guidelines. The app adapts gracefully to mobile (< 600px), tablet (600-840px), and desktop (>= 840px) screen sizes.

## Breakpoints

```dart
// lib/core/constants/app_breakpoints.dart
- Compact (Mobile): width < 600
- Medium (Tablet): 600 <= width < 840
- Expanded (Desktop): width >= 840
```

## New Files

### Core Utilities
- `lib/core/constants/app_breakpoints.dart` - Breakpoint constants
- `lib/core/constants/app_sizes.dart` - Size helper functions
- `lib/core/utils/adaptive/adaptive_breakpoints.dart` - Helper functions
- `lib/core/utils/adaptive/adaptive_builder.dart` - AdaptiveBuilder widget
- `lib/core/utils/adaptive/adaptive_destinations.dart` - Navigation destinations

### Adaptive Widgets
- `lib/core/widgets/adaptive/adaptive_grid.dart` - Responsive GridView
- `lib/core/widgets/adaptive/adaptive_dialog.dart` - Adaptive dialog widget

## Usage Examples

### AdaptiveBuilder - For 3-layout branching

```dart
import '../../../../core/utils/adaptive/adaptive_builder.dart';

AdaptiveBuilder(
  compact: (context) => MobileLayout(),
  medium: (context) => TabletLayout(),
  expanded: (context) => DesktopLayout(),
)
```

### AdaptiveBreakpoints - For helper functions

```dart
import '../../../../core/utils/adaptive/adaptive_breakpoints.dart';

// Check breakpoints
if (AdaptiveBreakpoints.isCompact(context)) {
  // Mobile
} else if (AdaptiveBreakpoints.isMedium(context)) {
  // Tablet
} else {
  // Desktop
}

// Get adaptive padding
final padding = AdaptiveBreakpoints.adaptivePadding(context);

// Get navigation rail width
final railWidth = AdaptiveBreakpoints.navigationRailWidth(context);
```

### AppSizes - For size calculations

```dart
import '../../../../core/constants/app_sizes.dart';

// Get horizontal padding
final hPadding = AppSizes.horizontalPadding(context);

// Get max width for content
final maxWidth = AppSizes.maxWidthForContent(context);

// Get grid max extent
final gridExtent = AppSizes.gridMaxExtent(context);
```

### AdaptiveGridView - For responsive grids

```dart
import '../../../../core/widgets/adaptive/adaptive_grid.dart';

AdaptiveGridView(
  padding: EdgeInsets.all(16),
  itemCount: items.length,
  mainAxisSpacing: 20,
  crossAxisSpacing: 20,
  childAspectRatio: 0.75,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

### Adaptive Dialog - For responsive dialogs

```dart
import '../../../../core/widgets/adaptive/adaptive_dialog.dart' as adaptive;

adaptive.showAdaptiveDialog(
  context: context,
  title: const Text('Dialog Title'),
  child: const Text('Dialog content'),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Close'),
    ),
  ],
);
```

### AppDestinations - For navigation

```dart
import '../../../../core/utils/adaptive/adaptive_destinations.dart';

// Use in NavigationRail
NavigationRail(
  destinations: AppDestinations.primary
      .map((d) => d.toNavigationRailDestination())
      .toList(),
)

// Use in BottomNavigationBar
BottomNavigationBar(
  items: AppDestinations.primary
      .map((d) => d.toBottomNavigationBarItem())
      .toList(),
)
```

## Layout Variants by Screen Size

### Mobile (< 600px)
- Bottom navigation bar
- Single column layout
- Full-width cards
- Compact spacing

### Tablet (600 - 840px)
- Navigation rail with selected labels
- 2-column layout for home page
- Grid adjusts to 2-3 columns
- Medium spacing

### Desktop (>= 840px)
- Navigation rail with all labels
- 2-column layout with fixed sidebar
- Grid adjusts to 3-4 columns
- Generous spacing
- Max width constraints for content

## Features Implemented

### Navigation
- ✅ Adaptive navigation (Rail ↔ BottomBar)
- ✅ Shared destination data
- ✅ Responsive drawer width

### Home Page
- ✅ 3 distinct layouts (mobile, tablet, desktop)
- ✅ Adaptive grid for menu items
- ✅ Hover states for desktop
- ✅ Responsive card layouts

### List Pages
- ✅ Adaptive grid for events
- ✅ Adaptive grid for donations
- ✅ Hover states and click feedback
- ✅ Max width constraints

### Settings & Profile
- ✅ Adaptive dialogs
- ✅ Max width constraints
- ✅ Hover states
- ✅ Responsive spacing

## Best Practices

1. **Always use AdaptiveBuilder** for layouts that need 3 variants
2. **Use AppSizes** for consistent spacing and sizing
3. **Add MouseRegion** with cursor for desktop interactivity
4. **Constrain content width** on large screens using `ConstrainedBox`
5. **Use adaptive dialogs** instead of regular `showDialog`
6. **Test on multiple screen sizes** during development

## Keyboard Navigation

The app supports keyboard navigation through:
- Tab/Shift+Tab for focus navigation
- Enter/Space to activate focused widgets
- Arrow keys for list navigation

## Testing

Test the app on these screen sizes:
- Mobile: 375x667 (iPhone SE), 390x844 (iPhone 14)
- Tablet: 768x1024 (iPad), 800x1280 (Tablet)
- Desktop: 1280x720, 1920x1080, 2560x1440
