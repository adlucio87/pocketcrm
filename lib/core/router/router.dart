import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pocketcrm/presentation/onboarding/welcome_screen.dart';
import 'package:pocketcrm/presentation/onboarding/instance_setup_screen.dart';
import 'package:pocketcrm/presentation/onboarding/api_token_screen.dart';
import 'package:pocketcrm/presentation/contacts/contacts_screen.dart';
import 'package:pocketcrm/presentation/contact_detail/contact_detail_screen.dart';
import 'package:pocketcrm/presentation/companies/companies_screen.dart';
import 'package:pocketcrm/presentation/companies/company_detail_screen.dart';
import 'package:pocketcrm/presentation/tasks/tasks_screen.dart';
import 'package:pocketcrm/presentation/settings/settings_screen.dart';
import 'package:pocketcrm/shared/main_shell.dart';
import 'package:pocketcrm/core/di/auth_state.dart';

part 'router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authNotifier = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) {
    authNotifier.value++;
  });
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      print(
        'Router redirect: matchedLocation=${state.matchedLocation}, authState=$authState',
      );

      // Aspettiamo che authState sia pronto
      if (authState.isLoading && !authState.hasValue) {
        print('Router redirect: waiting for authState');
        return '/'; // Mostra caricamento (Splash)
      }

      // Errore o valore nullo: tratta come non autenticato
      if (authState.hasError || authState.value == null) {
        print('Router redirect: allow null (error/null state)');
        return null;
      }

      final hasToken = authState.value!;
      final isOnboarding =
          state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation == '/';

      print('Router redirect: hasToken=$hasToken, isOnboarding=$isOnboarding');

      if (!hasToken && !isOnboarding) {
        print('Router redirect: -> /onboarding');
        return '/onboarding';
      }

      // Se non abbiamo token e siamo root, mandiamo a /onboarding
      if (!hasToken && state.matchedLocation == '/') {
        print('Router redirect: -> /onboarding from root');
        return '/onboarding';
      }

      if (hasToken && isOnboarding) {
        print('Router redirect: -> /contacts');
        return '/contacts';
      }

      print('Router redirect: allow null');
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/instance',
        builder: (context, state) => const InstanceSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/token',
        builder: (context, state) => const ApiTokenScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/contacts',
            builder: (context, state) => const ContactsScreen(),
          ),
          GoRoute(
            path: '/contacts/:id',
            builder: (context, state) =>
                ContactDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/companies',
            builder: (context, state) => const CompaniesScreen(),
          ),
          GoRoute(
            path: '/companies/:id',
            builder: (context, state) =>
                CompanyDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
