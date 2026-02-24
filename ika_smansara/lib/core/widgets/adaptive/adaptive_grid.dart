/// Adaptive Grid - Responsive GridView with adaptive maxCrossAxisExtent
library;

import 'package:flutter/material.dart';
import '../../constants/app_breakpoints.dart';

/// Adaptive grid view that adjusts column count based on screen size
class AdaptiveGridView extends StatelessWidget {
  const AdaptiveGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.childAspectRatio,
    this.shrinkWrap = false,
    this.physics,
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double? childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxExtent = _getMaxCrossAxisExtent(constraints.maxWidth);

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxExtent,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio:
                childAspectRatio ?? _getChildAspectRatio(maxExtent),
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }

  double _getMaxCrossAxisExtent(double constraintsWidth) {
    if (constraintsWidth >= AppBreakpoints.expandedDesktop) {
      return 350;
    } else if (constraintsWidth >= AppBreakpoints.mediumTablet) {
      return 300;
    }
    return 280;
  }

  double _getChildAspectRatio(double maxExtent) {
    return 0.75;
  }
}
