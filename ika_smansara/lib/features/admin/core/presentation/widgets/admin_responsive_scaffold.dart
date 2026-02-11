import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import 'admin_drawer.dart';
import 'admin_sidebar.dart';

class AdminResponsiveScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final bool hideBackButton;

  const AdminResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.hideBackButton = false,
  });

  @override
  State<AdminResponsiveScaffold> createState() =>
      _AdminResponsiveScaffoldState();
}

class _AdminResponsiveScaffoldState extends State<AdminResponsiveScaffold> {
  bool _isSidebarVisible = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leadingWidth:
                (!widget.hideBackButton && Navigator.of(context).canPop())
                ? 100
                : null,
            leading:
                widget.leading ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!widget.hideBackButton &&
                        Navigator.of(context).canPop())
                      const BackButton(color: AppColors.textDark),
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.textDark),
                        onPressed: () {
                          if (isDesktop) {
                            setState(() {
                              _isSidebarVisible = !_isSidebarVisible;
                            });
                          } else {
                            Scaffold.of(context).openDrawer();
                          }
                        },
                      ),
                    ),
                  ],
                ),
            title: Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            actions: widget.actions,
          ),
          drawer: isDesktop ? null : const AdminDrawer(),
          floatingActionButton: widget.floatingActionButton,
          body: SafeArea(
            top: false,
            child: Row(
              children: [
                if (isDesktop && _isSidebarVisible)
                  AdminSidebar(showHeader: false, isPermanent: true),
                Expanded(child: widget.body),
              ],
            ),
          ),
        );
      },
    );
  }
}
