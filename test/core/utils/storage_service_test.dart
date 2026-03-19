import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketcrm/core/utils/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('StorageService', () {
    late StorageService storageService;
    late Box<String> box;

    setUp(() async {
      // Usa Hive in memoria per i test
      Hive.init('/tmp/hive_test');
      box = await Hive.openBox<String>('test_storage');

      FlutterSecureStorage.setMockInitialValues({});
      const secureStorage = FlutterSecureStorage();
      storageService = StorageService(secureStorage, box);
    });

    tearDown(() async {
      await box.clear();
      await box.close();
    });

    test('writes non-sensitive keys to Hive', () async {
      await storageService.write(key: 'user_name', value: 'John Doe');

      expect(box.get('user_name'), 'John Doe');
    });

    test('does NOT write sensitive keys to Hive', () async {
      await storageService.write(key: 'api_token', value: 'secret123');
      await storageService.write(
        key: 'instance_url',
        value: 'https://example.com',
      );

      expect(box.get('api_token'), null);
      expect(box.get('instance_url'), null);
    });

    test('removes key from Hive when value is null', () async {
      await box.put('user_name', 'John Doe');
      await storageService.write(key: 'user_name', value: null);

      expect(box.get('user_name'), null);
    });

    test('reads from Hive fallback when not in cache or secure storage', () async {
      await box.put('user_name', 'John Doe');

      final result = await storageService.read(key: 'user_name');
      expect(result, 'John Doe');
    });

    test('does NOT read sensitive keys from Hive', () async {
      // Even if somehow a sensitive key gets into Hive, it should not read it
      await box.put('api_token', 'old_token_123');

      final result = await storageService.read(key: 'api_token');

      expect(result, null);
    });
  });
}
