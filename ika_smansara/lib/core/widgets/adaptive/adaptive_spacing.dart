/// Adaptive Spacing - Responsive spacing replacement for SizedBox
library;

import 'package:flutter/widgets.dart';
import '../../constants/app_breakpoints.dart';

/// Adaptive spacing widget that provides responsive spacing based on screen size
class AdaptiveSpacing extends StatelessWidget {
  const AdaptiveSpacing({
    super.key,
    this.multiplier = 1.0,
    this.axis = Axis.vertical,
  });

  /// Multiplier for base spacing (0.5, 1.0, 1.5, 2.0, etc.)
  final double multiplier;

  /// Axis direction (vertical for height, horizontal for width)
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final baseSpacing = _getBaseSpacing(context);
    final spacing = baseSpacing * multiplier;

    return axis == Axis.vertical
        ? SizedBox(height: spacing)
        : SizedBox(width: spacing);
  }

  double _getBaseSpacing(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return 8.0;
    } else if (width >= AppBreakpoints.mediumTablet) {
      return 6.0;
    }
    return 4.0;
  }
}

/// Vertical spacing (SizedBox.height)
class AdaptiveSpacingV extends StatelessWidget {
  const AdaptiveSpacingV({super.key, this.multiplier = 1.0});

  final double multiplier;

  @override
  Widget build(BuildContext context) {
    return AdaptiveSpacing(multiplier: multiplier, axis: Axis.vertical);
  }
}

/// Horizontal spacing (SizedBox.width)
class AdaptiveSpacingH extends StatelessWidget {
  const AdaptiveSpacingH({super.key, this.multiplier = 1.0});

  final double multiplier;

  @override
  Widget build(BuildContext context) {
    return AdaptiveSpacing(multiplier: multiplier, axis: Axis.horizontal);
  }
}

/// Sliver adaptive spacing for CustomScrollView
class AdaptiveSliverSpacing extends StatelessWidget {
  const AdaptiveSliverSpacing({super.key, this.multiplier = 1.0});

  final double multiplier;

  @override
  Widget build(BuildContext context) {
    final spacing = AdaptiveSpacing(multiplier: multiplier);
    return SliverToBoxAdapter(child: spacing);
  }
}
