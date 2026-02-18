/// Adaptive Builder - Widget for breakpoint-based UI branching
library;

import 'package:flutter/widgets.dart';

/// Builder function type for compact (mobile) layout
typedef CompactBuilder = Widget Function(BuildContext context);

/// Builder function type for medium (tablet) layout
typedef MediumBuilder = Widget Function(BuildContext context);

/// Builder function type for expanded (desktop) layout
typedef ExpandedBuilder = Widget Function(BuildContext context);

/// Adaptive builder that switches between compact, medium, and expanded layouts
class AdaptiveBuilder extends StatelessWidget {
  const AdaptiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  /// Compact layout (width < 600)
  final CompactBuilder compact;

  /// Medium layout (600 <= width < 840), falls back to compact if null
  final MediumBuilder? medium;

  /// Expanded layout (width >= 840), falls back to medium if null
  final ExpandedBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 840 && expanded != null) {
      return expanded!(context);
    } else if (width >= 600 && medium != null) {
      return medium!(context);
    }
    return compact(context);
  }
}

/// Layout-based adaptive builder for local constraint decisions
class AdaptiveLayoutBuilder extends StatelessWidget {
  const AdaptiveLayoutBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final CompactBuilder compact;
  final MediumBuilder? medium;
  final ExpandedBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840 && expanded != null) {
          return expanded!(context);
        } else if (constraints.maxWidth >= 600 && medium != null) {
          return medium!(context);
        }
        return compact(context);
      },
    );
  }
}
