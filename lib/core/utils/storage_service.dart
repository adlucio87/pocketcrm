import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _fallback;
  final Map<String, String> _cache = {};

  static const _sensitiveKeys = <String>{};

  StorageService(this._secureStorage, this._fallback);

  Future<void> write({required String key, required String? value}) async {
    if (value != null) {
      _cache[key] = value;
    } else {
      _cache.remove(key);
    }

    if (kDebugMode) print('StorageService: Writing $key -> $value');

    final bool isMacOSDebug =
        kDebugMode && defaultTargetPlatform == TargetPlatform.macOS;
    final bool blockPlaintext = _sensitiveKeys.contains(key) && !isMacOSDebug;

    // Only write to SharedPreferences fallback if it's not a sensitive key (except for macOS debug workaround)
    if (!blockPlaintext) {
      if (value != null) {
        await _fallback.setString(key, value);
      } else {
        await _fallback.remove(key);
      }
    } else {
      // If we are deleting a sensitive key, ensure it's removed from fallback too
      // just in case it was leaked previously
      if (value == null) {
        await _fallback.remove(key);
      }
    }

    try {
      await _secureStorage.write(key: key, value: value);
      if (kDebugMode) print('StorageService: $key written to secure storage');
    } catch (e) {
      if (kDebugMode) {
        if (e.toString().contains('-34018')) {
          print(
            'StorageService: Keychain locked (-34018). Secure storage skipped for "$key".',
          );
        } else {
          print('StorageService: Error writing "$key" to secure storage ($e).');
        }
      }
    }
  }

  Future<String?> read({required String key}) async {
    if (_cache.containsKey(key)) {
      if (kDebugMode) {
        print('StorageService: $key read from in-memory cache');
      }
      return _cache[key];
    }

    String? secureValue;
    try {
      secureValue = await _secureStorage.read(key: key);
      if (kDebugMode && secureValue != null) {
        print('StorageService: $key read from secure storage');
      }
    } catch (e) {
      if (kDebugMode && !e.toString().contains('-34018')) {
        print('StorageService: Error reading "$key" from secure storage ($e).');
      }
    }

    if (secureValue != null) {
      _cache[key] = secureValue;
      return secureValue;
    }

    final bool isMacOSDebug =
        kDebugMode && defaultTargetPlatform == TargetPlatform.macOS;
    final bool blockPlaintext = _sensitiveKeys.contains(key) && !isMacOSDebug;

    // Do not read sensitive keys from the plaintext fallback (except for macOS debug workaround)
    if (blockPlaintext) {
      return null;
    }

    final fallbackValue = _fallback.getString(key);
    if (kDebugMode && fallbackValue != null) {
      print('StorageService: $key read from SharedPreferences fallback');
    }

    if (fallbackValue != null) {
      _cache[key] = fallbackValue;
    }

    return fallbackValue;
  }

  Future<void> delete({required String key}) async {
    _cache.remove(key);
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {}
    await _fallback.remove(key);
  }

  Future<void> deleteAll() async {
    _cache.clear();
    try {
      await _secureStorage.deleteAll();
    } catch (e) {}
    await _fallback.clear();
  }
}
