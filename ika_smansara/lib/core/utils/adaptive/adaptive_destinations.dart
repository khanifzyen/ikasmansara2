/// Adaptive Destinations - Shared navigation data for NavigationRail and BottomNavigationBar
library;

import 'package:flutter/material.dart';

/// Navigation destination data for adaptive navigation
class AdaptiveDestination {
  const AdaptiveDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// Convert to NavigationRailDestination
  NavigationRailDestination toNavigationRailDestination() {
    return NavigationRailDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: Text(label),
    );
  }

  /// Convert to BottomNavigationBarItem
  BottomNavigationBarItem toBottomNavigationBarItem() {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(selectedIcon),
      label: label,
    );
  }
}

/// Navigation destinations for main app navigation
class AppDestinations {
  AppDestinations._();

  static const List<AdaptiveDestination> primary = [
    AdaptiveDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    AdaptiveDestination(
      label: 'Donasiku',
      icon: Icons.volunteer_activism_outlined,
      selectedIcon: Icons.volunteer_activism,
    ),
    AdaptiveDestination(
      label: 'Tiketku',
      icon: Icons.confirmation_number_outlined,
      selectedIcon: Icons.confirmation_number,
    ),
    AdaptiveDestination(
      label: 'Loker',
      icon: Icons.work_outline,
      selectedIcon: Icons.work,
    ),
    AdaptiveDestination(
      label: 'Lainnya',
      icon: Icons.menu,
      selectedIcon: Icons.menu,
    ),
  ];

  static const int homeIndex = 0;
  static const int donationsIndex = 1;
  static const int ticketsIndex = 2;
  static const int lokerIndex = 3;
  static const int moreIndex = 4;
}
