import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:flutter/widgets.dart';

void main() {
  test('Check if crmRepository is rebuilt', () async {
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

    int buildCount = 0;

    // We can't easily intercept the provider build, but we can look at the time.
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      await container.read(crmRepositoryProvider.future);
    }
    stopwatch.stop();
    print('1000 repo reads (no invalidation) took ${stopwatch.elapsedMilliseconds} ms');
  });
}
