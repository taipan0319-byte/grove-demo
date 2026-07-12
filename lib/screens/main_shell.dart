import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import 'city_dashboard_screen.dart';
import 'forest_screen.dart';
import 'grove_screen.dart';
import 'home_screen.dart';
import 'log_activity_screen.dart';
import 'marketplace_screen.dart';
import 'profile_screen.dart';

/// Root scaffold: 6-tab bottom navigation + profile avatar in the app bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = [
    'My Tree',
    'Log Activity',
    'My Grove',
    'Employer Forest',
    'Marketplace',
    'City Dashboard',
  ];

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final screens = [
      HomeScreen(onLogActivity: () => _goTo(1)),
      LogActivityScreen(onSeeTree: () => _goTo(0)),
      const GroveScreen(),
      const ForestScreen(),
      const MarketplaceScreen(),
      const CityDashboardScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index], style: groveSerif(size: 22)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: GroveColors.forest,
                child: Text(
                  state.profile?.initials ?? '?',
                  style: const TextStyle(
                    color: GroveColors.cream,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _goTo,
        type: BottomNavigationBarType.fixed,
        backgroundColor: GroveColors.card,
        selectedItemColor: GroveColors.forest,
        unselectedItemColor: GroveColors.textMuted,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.park_outlined),
              activeIcon: Icon(Icons.park),
              label: 'My Tree'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Log'),
          BottomNavigationBarItem(
              icon: Icon(Icons.forest_outlined),
              activeIcon: Icon(Icons.forest),
              label: 'Grove'),
          BottomNavigationBarItem(
              icon: Icon(Icons.landscape_outlined),
              activeIcon: Icon(Icons.landscape),
              label: 'Forest'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Market'),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_city_outlined),
              activeIcon: Icon(Icons.location_city),
              label: 'City'),
        ],
      ),
    );
  }
}
