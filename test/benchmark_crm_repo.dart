import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:flutter/widgets.dart';

void main() {
  test('Benchmark CRM Repository', () async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'instance_url': 'https://example.com',
      'api_token': 'test_token',
    });

    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 100; i++) {
      final storage = container.read(storageServiceProvider);
      await storage.read(key: 'instance_url');
      await storage.read(key: 'api_token');
    }
    stopwatch.stop();
    print('100 reads took ${stopwatch.elapsedMilliseconds} ms');
  });
}
