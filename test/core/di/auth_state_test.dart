import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pocketcrm/core/di/auth_state.dart';
import 'package:pocketcrm/core/di/providers.dart' hide isDemoModeProvider;
import 'package:pocketcrm/core/utils/demo_utils.dart';
import 'package:pocketcrm/core/utils/storage_service.dart';

class MockStorageService extends Mock implements StorageService {
  final Map<String, String> _data = {};

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({required String key}) async {
    return _data[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }
}

void main() {
  late MockStorageService mockStorage;
  late ProviderContainer container;

  setUp(() {
    mockStorage = MockStorageService();
    container = ProviderContainer(
      overrides: [storageServiceProvider.overrideWithValue(mockStorage)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('login sets api_token and is_demo_mode to false by default', () async {
    await container.read(authStateProvider.notifier).login('test_token');

    expect(await mockStorage.read(key: 'api_token'), 'test_token');
    expect(await mockStorage.read(key: 'is_demo_mode'), 'false');
  });

  test('login sets is_demo_mode to true when requested', () async {
    await container
        .read(authStateProvider.notifier)
        .login('demo_token', isDemo: true);

    expect(await mockStorage.read(key: 'api_token'), 'demo_token');
    expect(await mockStorage.read(key: 'is_demo_mode'), 'true');
  });

  test('login overrides existing demo mode flag', () async {
    // Start with demo mode true
    await mockStorage.write(key: 'is_demo_mode', value: 'true');

    // Login with personal instance
    await container.read(authStateProvider.notifier).login('personal_token');

    expect(await mockStorage.read(key: 'is_demo_mode'), 'false');
  });

  test('isDemoModeProvider reacts to authStateProvider changes', () async {
    // Initially false (no data in storage)
    expect(await container.read(isDemoModeProvider.future), false);

    // Login as demo
    await container
        .read(authStateProvider.notifier)
        .login('demo_token', isDemo: true);

    // Should now be true
    expect(await container.read(isDemoModeProvider.future), true);

    // Logout
    await container.read(authStateProvider.notifier).logout();

    // Should now be false
    expect(await container.read(isDemoModeProvider.future), false);
  });
}
