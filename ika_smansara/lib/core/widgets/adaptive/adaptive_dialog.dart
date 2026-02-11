/// Adaptive Dialog - Responsive dialog that shows modal or fullscreen based on screen size
library;

import 'package:flutter/material.dart';
import '../../constants/app_breakpoints.dart';

/// Adaptive dialog that shows as fullscreen on mobile and modal on tablet/desktop
class AdaptiveDialog extends StatelessWidget {
  const AdaptiveDialog({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.contentPadding,
    this.backgroundColor,
    this.elevation,
  });

  final Widget child;
  final Widget? title;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mediumTablet) {
          return _buildFullscreenDialog(context);
        }
        return _buildModalDialog(context);
      },
    );
  }

  Widget _buildFullscreenDialog(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor,
      elevation: elevation,
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: DefaultTextStyle(
                        style: Theme.of(context).textTheme.headlineSmall!,
                        child: title!,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: contentPadding ?? const EdgeInsets.all(16),
                child: child,
              ),
            ),
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalDialog(BuildContext context) {
    final maxWidth = AppBreakpoints.maxFormWidth.toDouble();

    return Dialog(
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleLarge!,
                  child: title!,
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding:
                    contentPadding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: child,
              ),
            ),
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show adaptive dialog
Future<T?> showAdaptiveDialog<T>({
  required BuildContext context,
  required Widget child,
  Widget? title,
  List<Widget>? actions,
  EdgeInsetsGeometry? contentPadding,
  Color? backgroundColor,
  double? elevation,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => AdaptiveDialog(
      title: title,
      actions: actions,
      contentPadding: contentPadding,
      backgroundColor: backgroundColor,
      elevation: elevation,
      child: child,
    ),
  );
}
