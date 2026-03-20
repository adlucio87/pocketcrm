import 'package:pocketcrm/core/di/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<bool> build() async {
    print('AuthState: build started');
    final storage = ref.read(storageServiceProvider);
    final token = await storage.read(key: 'api_token');
    final url = await storage.read(key: 'instance_url');
    print('AuthState: read token -> ${token != null}, url -> ${url != null}');
    return token != null && url != null;
  }

  Future<void> login(String token) async {
    final storage = ref.read(storageServiceProvider);
    await storage.write(key: 'api_token', value: token);
    state = const AsyncValue.data(true);
  }

  Future<void> logout() async {
    final storage = ref.read(storageServiceProvider);
    await storage.delete(key: 'api_token');
    await storage.delete(key: 'is_demo_mode');
    state = const AsyncValue.data(false);
  }
}
