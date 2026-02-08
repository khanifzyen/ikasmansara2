import 'package:flutter/material.dart';
import 'admin_sidebar.dart';

/// Admin Drawer - Hamburger menu for admin navigation (refactored to use AdminSidebar)
class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(child: AdminSidebar(isPermanent: false)),
    );
  }
}
