/// Main Shell - Adaptive navigation with 3 breakpoints
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_breakpoints.dart';
import '../../../../core/utils/adaptive/adaptive_builder.dart';
import '../../../../core/utils/adaptive/adaptive_breakpoints.dart';
import '../../../../core/utils/adaptive/adaptive_destinations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({required this.navigationShell, super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int get _selectedIndex {
    final index = widget.navigationShell.currentIndex;
    if (index > 3) return AppDestinations.moreIndex;
    return index;
  }

  void _onTap(int index) {
    if (index == AppDestinations.moreIndex) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: const _SideDrawer(),
        body: AdaptiveBuilder(
          compact: (context) => _buildMobileLayout(context),
          medium: (context) => _buildTabletLayout(context),
          expanded: (context) => _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.navigationShell),
        BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTap,
          type: BottomNavigationBarType.fixed,
          items: AppDestinations.primary
              .map((d) => d.toBottomNavigationBarItem())
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: AppBreakpoints.navRailWidthCompact,
          child: NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onTap,
            labelType: NavigationRailLabelType.selected,
            destinations: AppDestinations.primary
                .map((d) => d.toNavigationRailDestination())
                .toList(),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: widget.navigationShell),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: AppBreakpoints.navRailWidthExpanded,
          child: NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onTap,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Image.asset(
                'assets/images/logo-ika.png',
                width: 40,
                height: 40,
              ),
            ),
            destinations: AppDestinations.primary
                .map((d) => d.toNavigationRailDestination())
                .toList(),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: widget.navigationShell),
      ],
    );
  }
}

class _SideDrawer extends StatelessWidget {
  const _SideDrawer();

  @override
  Widget build(BuildContext context) {
    final drawerWidth = AdaptiveBreakpoints.drawerWidth(context);

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(0)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildMenuItems(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Menu Lainnya',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _DrawerItem(
          icon: Icons.people_outline,
          label: 'Direktori',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur Direktori akan segera hadir'),
              ),
            );
          },
        ),
        _DrawerItem(
          icon: Icons.shopping_bag_outlined,
          label: 'Market',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur Market akan segera hadir')),
            );
          },
        ),
        _DrawerItem(
          icon: Icons.forum_outlined,
          label: 'Forum Diskusi',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur Forum Diskusi akan segera hadir'),
              ),
            );
          },
        ),
        _DrawerItem(
          icon: Icons.person_outline,
          label: 'Profil',
          onTap: () {
            Navigator.pop(context);
            context.push('/profile');
          },
        ),
        const Divider(height: 32, color: AppColors.border),
        _DrawerItem(
          icon: Icons.logout,
          label: 'Keluar',
          onTap: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(AuthLogoutRequested());
          },
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
