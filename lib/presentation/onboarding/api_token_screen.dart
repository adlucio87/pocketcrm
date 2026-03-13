import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/core/di/auth_state.dart';

class ApiTokenScreen extends ConsumerStatefulWidget {
  const ApiTokenScreen({super.key});

  @override
  ConsumerState<ApiTokenScreen> createState() => _ApiTokenScreenState();
}

class _ApiTokenScreenState extends ConsumerState<ApiTokenScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStoredToken();
  }

  Future<void> _loadStoredToken() async {
    final storage = ref.read(storageServiceProvider);
    final token = await storage.read(key: 'api_token');
    if (token != null) {
      setState(() {
        _controller.text = token;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Token')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Enter your Twenty CRM API Token.'),
              const SizedBox(height: 8),
              const Text(
                'Where can I find the token? Twenty → Settings → API & Webhooks',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'API Token',
                  hintText: 'Enter token...',
                  prefixIcon: const Icon(Icons.key),
                  errorText: _error,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter a token';
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Connect'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final storage = ref.read(storageServiceProvider);
      final baseUrl = await storage.read(key: 'instance_url');
      if (baseUrl == null) throw Exception('Instance URL missing');

      final token = _controller.text.trim();

      // Salva il token e aggiorna authState → il router si occuperà del redirect
      await ref.read(authStateProvider.notifier).login(token);
      ref.invalidate(crmRepositoryProvider);

      if (mounted) context.go('/onboarding/notifications');
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
