/// Adaptive Container - Auto-constrains content width based on type
library;

import 'package:flutter/widgets.dart';
import '../../constants/app_breakpoints.dart';

/// Container type for different max width constraints
enum AdaptiveWidthType {
  /// Maximum content width for readability (1200px)
  content,

  /// Maximum form width for optimal usability (600px)
  form,

  /// Maximum card width for consistent layouts (400px)
  card,
}

/// Adaptive container that constrains content width based on screen size and type
class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({
    super.key,
    required this.child,
    this.widthType = AdaptiveWidthType.content,
    this.alignment = Alignment.center,
    this.padding,
  });

  final Widget child;
  final AdaptiveWidthType widthType;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final maxWidth = _getMaxWidth();

    return Container(
      alignment: alignment,
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  double _getMaxWidth() {
    switch (widthType) {
      case AdaptiveWidthType.content:
        return AppBreakpoints.maxContentWidth;
      case AdaptiveWidthType.form:
        return AppBreakpoints.maxFormWidth;
      case AdaptiveWidthType.card:
        return AppBreakpoints.maxCardWidth;
    }
  }
}

/// Adaptive container that centers content and constrains width
class AdaptiveCenter extends StatelessWidget {
  const AdaptiveCenter({
    super.key,
    required this.child,
    this.widthType = AdaptiveWidthType.content,
  });

  final Widget child;
  final AdaptiveWidthType widthType;

  @override
  Widget build(BuildContext context) {
    return AdaptiveContainer(widthType: widthType, child: child);
  }
}
