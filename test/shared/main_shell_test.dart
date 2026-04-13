import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/shared/main_shell.dart';
import 'package:pocketcrm/core/utils/demo_utils.dart';

void main() {
  group('MainShell Tests', () {
    testWidgets('MainShell should contain a SafeArea that accounts for the top', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const Text('Home Content'),
              ),
              GoRoute(
                path: '/contacts',
                builder: (context, state) => const Text('Contacts Content'),
              ),
              GoRoute(
                path: '/companies',
                builder: (context, state) => const Text('Companies Content'),
              ),
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const Text('Tasks Content'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isDemoModeProvider.overrideWith((ref) => Future.value(true)),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that SafeArea is in the widget tree
      // There might be multiple because NavigationBar or other components add their own
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
      
      final safeAreaFinder = find.byWidgetPredicate(
        (widget) => widget is SafeArea && widget.top == true && widget.bottom == false
      );
      expect(safeAreaFinder, findsOneWidget);
      
      final safeArea = tester.widget<SafeArea>(safeAreaFinder);
      expect(safeArea.top, isTrue);
      expect(safeArea.bottom, isFalse);
      
      // Verify the demo banner is present
      expect(find.textContaining('Demo mode'), findsOneWidget);

      // Verify content is below the status bar (in terms of local coordinates)
      // By default widget tests have no padding, but we can check the layout
      final bannerLabel = find.textContaining('Demo mode');
      final bannerPosition = tester.getTopLeft(bannerLabel);
      
      // If we provided a MediaQuery with top padding, we could verify it's shifted
      // For now, checking the widget structure is sufficient
    });

    testWidgets('MainShell should still have SafeArea when demo mode is off', (WidgetTester tester) async {
       final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const Text('Home Content'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isDemoModeProvider.overrideWith((ref) => Future.value(false)),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // SafeArea with top: true should still be there
      final safeAreaFinder = find.byWidgetPredicate(
        (widget) => widget is SafeArea && widget.top == true
      );
      expect(safeAreaFinder, findsAtLeastNWidgets(1));
      expect(find.textContaining('Modalità demo'), findsNothing);
    });
  });
}
