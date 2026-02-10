import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
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

  void _onTap(int index) {
    if (index == 4) {
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;

          if (isDesktop) {
            return Scaffold(
              key: _scaffoldKey,
              endDrawer: const _SideDrawer(),
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: widget.navigationShell.currentIndex > 3
                        ? 4
                        : widget.navigationShell.currentIndex,
                    onDestinationSelected: _onTap,
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.volunteer_activism_outlined),
                        selectedIcon: Icon(Icons.volunteer_activism),
                        label: Text('Donasiku'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.confirmation_number_outlined),
                        selectedIcon: Icon(Icons.confirmation_number),
                        label: Text('Tiketku'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.work_outline),
                        selectedIcon: Icon(Icons.work),
                        label: Text('Loker'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.menu),
                        label: Text('Lainnya'),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: widget.navigationShell),
                ],
              ),
            );
          }

          return Scaffold(
            key: _scaffoldKey,
            body: widget.navigationShell,
            endDrawer: const _SideDrawer(),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: widget.navigationShell.currentIndex > 3
                  ? 3
                  : widget.navigationShell.currentIndex,
              onTap: _onTap,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.volunteer_activism_outlined),
                  activeIcon: Icon(Icons.volunteer_activism),
                  label: 'Donasiku',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_number_outlined),
                  activeIcon: Icon(Icons.confirmation_number),
                  label: 'Tiketku',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.work_outline),
                  activeIcon: Icon(Icons.work),
                  label: 'Loker',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Lainnya',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SideDrawer extends StatelessWidget {
  const _SideDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(0)),
      ),
      child: Column(
        children: [
          Container(
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
          ),
          Expanded(
            child: ListView(
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
                    // context.push('/directory');
                  },
                ),
                // Placeholders for future phases
                _DrawerItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Market',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur Market akan segera hadir'),
                      ),
                    );
                    // context.push('/market'); // Phase 8
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
                    // context.push('/forum');
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
                    Navigator.pop(context); // Close drawer
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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
