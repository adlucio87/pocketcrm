import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/core/utils/demo_utils.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider).valueOrNull ?? false;

    return Scaffold(
      body: Column(
        children: [
          if (isDemo)
            Container(
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
                  '🎭 Modalità demo · I dati si ripristinano ogni notte',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Scaffold(body: child),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
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
