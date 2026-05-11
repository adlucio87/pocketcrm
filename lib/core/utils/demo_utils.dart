import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/core/di/auth_state.dart';

final isDemoModeProvider = FutureProvider<bool>((ref) async {
  // Watch auth state to re-run this provider when login/logout occurs
  ref.watch(authStateProvider);
  
  final storage = ref.read(storageServiceProvider);
  final isDemo = await storage.read(key: 'is_demo_mode');
  return isDemo == 'true';
});

class DemoUtils {
  static Future<bool> isDemoMode(WidgetRef ref) async {
    final storage = ref.read(storageServiceProvider);
    final isDemo = await storage.read(key: 'is_demo_mode');
    return isDemo == 'true';
  }

  static Future<bool> checkDemoAction(BuildContext context, WidgetRef ref) async {
    final isDemo = await isDemoMode(ref);
    if (!isDemo) return true;

    if (context.mounted) {
      showDemoBlockSheet(context);
    }
    return false;
  }

  static void showDemoBlockSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _DemoBlockSheet(),
    );
  }

}

class _DemoBlockSheet extends ConsumerWidget {
  const _DemoBlockSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                'Feature not available in demo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Connect your Twenty instance to use all TwentyMobile features.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Reset session and navigate back to onboarding
                    ref.read(authStateProvider.notifier).logout();
                    context.pop();
                    context.go('/onboarding/instance');
                  },
                  child: const Text('Connect my instance'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Continue in demo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

