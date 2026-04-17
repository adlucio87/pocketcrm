import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/core/utils/demo_utils.dart';
import 'package:pocketcrm/core/utils/responsive.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider).valueOrNull ?? false;
    final isTablet = Responsive.isTablet(context);
    final selectedIndex = _calculateSelectedIndex(context);

    final demoBanner = isDemo
        ? Container(
            height: 28,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              border: const Border(
                bottom: BorderSide(color: Colors.amber, width: 1),
              ),
            ),
            child: const Center(
              child: Text(
                '🎭 Demo mode · Data is reset every night',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        : null;

    // ── Tablet layout: NavigationRail on the left ──
    if (isTablet) {
      return Scaffold(
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              if (demoBanner != null) demoBanner,
              Expanded(
                child: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (int index) =>
                          _onItemTapped(index, context),
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.people_outlined),
                          selectedIcon: Icon(Icons.people),
                          label: Text('Contacts'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.business_outlined),
                          selectedIcon: Icon(Icons.business),
                          label: Text('Companies'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.task_outlined),
                          selectedIcon: Icon(Icons.task),
                          label: Text('Tasks'),
                        ),
                      ],
                    ),
                    const VerticalDivider(width: 1, thickness: 1),
                    Expanded(child: Scaffold(body: child)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Phone layout: Bottom NavigationBar ──
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            if (demoBanner != null) demoBanner,
            Expanded(child: Scaffold(body: child)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.business), label: 'Companies'),
          NavigationDestination(icon: Icon(Icons.task), label: 'Tasks'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/contacts')) return 1;
    if (location.startsWith('/companies')) return 2;
    if (location.startsWith('/tasks')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/contacts');
        break;
      case 2:
        context.go('/companies');
        break;
      case 3:
        context.go('/tasks');
        break;
    }
  }
}
