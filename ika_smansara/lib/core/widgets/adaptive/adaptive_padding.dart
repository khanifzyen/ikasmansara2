/// Adaptive Padding - Responsive padding based on screen size
library;

import 'package:flutter/widgets.dart';
import '../../constants/app_breakpoints.dart';

/// Adaptive padding that adjusts based on screen size
class AdaptivePadding extends StatelessWidget {
  const AdaptivePadding({
    super.key,
    required this.child,
    this.all = false,
    this.horizontal = false,
    this.vertical = false,
    this.top = false,
    this.bottom = false,
    this.left = false,
    this.right = false,
    this.multiplier = 1.0,
  });

  final Widget child;
  final bool all;
  final bool horizontal;
  final bool vertical;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final double multiplier;

  @override
  Widget build(BuildContext context) {
    final padding = _getPadding(context);
    return Padding(padding: padding, child: child);
  }

  EdgeInsets _getPadding(BuildContext context) {
    final basePadding = _getBasePadding(context) * multiplier;

    if (all) {
      return EdgeInsets.all(basePadding);
    }
    return EdgeInsets.only(
      top: vertical || top ? basePadding : 0,
      bottom: vertical || bottom ? basePadding : 0,
      left: horizontal || left ? basePadding : 0,
      right: horizontal || right ? basePadding : 0,
    );
  }

  double _getBasePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expandedDesktop) {
      return 32.0;
    } else if (width >= AppBreakpoints.mediumTablet) {
      return 24.0;
    }
    return 16.0;
  }
}

/// Adaptive symmetric padding helper
class AdaptivePaddingSymmetric extends StatelessWidget {
  const AdaptivePaddingSymmetric({
    super.key,
    required this.child,
    this.horizontal = false,
    this.vertical = false,
    this.multiplier = 1.0,
  });

  final Widget child;
  final bool horizontal;
  final bool vertical;
  final double multiplier;

  @override
  Widget build(BuildContext context) {
    return AdaptivePadding(
      horizontal: horizontal,
      vertical: vertical,
      multiplier: multiplier,
      child: child,
    );
  }
}

/// Adaptive all-side padding helper
class AdaptivePaddingAll extends StatelessWidget {
  const AdaptivePaddingAll({
    super.key,
    required this.child,
    this.multiplier = 1.0,
  });

  final Widget child;
  final double multiplier;

  @override
  Widget build(BuildContext context) {
    return AdaptivePadding(all: true, multiplier: multiplier, child: child);
  }
}
