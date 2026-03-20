import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/core/di/providers.dart';

final isDemoModeProvider = FutureProvider<bool>((ref) async {
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
      showModalBottomSheet(
        context: context,
        builder: (context) => const _DemoBlockSheet(),
      );
    }
    return false;
  }
}

class _DemoBlockSheet extends StatelessWidget {
  const _DemoBlockSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Funzione non disponibile in demo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Connetti la tua istanza Twenty per usare tutte le funzionalità di TwentyMobile.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.pop();
                context.go('/onboarding/instance');
              },
              child: const Text('Connetti la mia istanza'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.pop(),
              child: const Text('Continua in demo'),
            ),
          ),
        ],
      ),
    );
  }
}
