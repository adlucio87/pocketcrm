import 'package:flutter_test/flutter_test.dart';
import 'package:pocketcrm/core/utils/storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

void main() {
  test('Benchmark storage.read multiple times', () async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'instance_url': 'https://example.com',
      'api_token': 'test_token',
    });

    final prefs = await SharedPreferences.getInstance();
    final secure = FlutterSecureStorage();
    final storage = StorageService(secure, prefs);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 100; i++) {
      await storage.read(key: 'instance_url');
      await storage.read(key: 'api_token');
    }
    stopwatch.stop();
    print('100 reads took ${stopwatch.elapsedMilliseconds} ms');
  });
}
