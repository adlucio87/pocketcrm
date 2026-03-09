import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:flutter/widgets.dart';

void main() {
  test('Benchmark Repo Methods', () async {
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
    for (int i = 0; i < 1000; i++) {
      // simulate a method calling ref.watch(crmRepositoryProvider.future)
      // wait, `ref.watch` in a provider doesn't recalculate unless the dependency changes.
      // let's look at the providers.dart:
      // @riverpod class Contacts extends _$Contacts {
      //   @override FutureOr<List<Contact>> build() async {
      //      final repo = await ref.watch(crmRepositoryProvider.future);
      //      ...
      //   }
      //   Future<void> search(String query) async {
      //      final repo = await ref.watch(crmRepositoryProvider.future);
      //   }
      // }
      //
      // Oh wait, `ref.watch(crmRepositoryProvider.future)` re-uses the cached Future if it's already complete!
      // But the issue mentions: "Uncached Repository Initialization".
      // "By caching the URL and token in memory (or relying on AuthState), we can skip the `await storage.read` calls on every CRM action. Modifying Riverpod's KeepAlive state or caching these on startup is a clear, self-contained fix."
      // Let's check if crmRepositoryProvider is invalidated somewhere.

      // Let's just create the benchmark that instantiates the repository multiple times.
    }
    stopwatch.stop();
  });
}
