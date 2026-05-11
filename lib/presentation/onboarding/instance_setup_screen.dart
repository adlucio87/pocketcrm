import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/core/di/auth_state.dart';
import 'package:pocketcrm/core/config/demo_config.dart';
import 'package:pocketcrm/presentation/shared/snackbar_helper.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class InstanceSetupScreen extends ConsumerStatefulWidget {
  const InstanceSetupScreen({super.key});

  @override
  ConsumerState<InstanceSetupScreen> createState() =>
      _InstanceSetupScreenState();
}

class _InstanceSetupScreenState extends ConsumerState<InstanceSetupScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isDemoLoading = false;
  bool _isNextLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStoredUrl();
  }

  Future<void> _trackServerConnection(
    String serverUrl, {
    required bool isDemo,
  }) async {
    await Sentry.captureMessage(
      'app_connected',
      level: SentryLevel.info,
      withScope: (scope) {
        scope.setTag('server_type', isDemo ? 'demo' : 'own_server');
        scope.setContexts('connection', {
          'is_demo': isDemo,
          'platform': Theme.of(context).platform.name,
        });
      },
    );
  }

  Future<void> _loadStoredUrl() async {
    final storage = ref.read(storageServiceProvider);
    final url = await storage.read(key: 'instance_url');
    if (url != null) {
      setState(() {
        _controller.text = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure CRM')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                onPressed: _isDemoLoading ? null : _connectDemo,
                icon: _isDemoLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_circle_outline),
                label: const Text('Try the demo'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Example data · No configuration required\nData is reset every night',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              const Text('What is your Twenty CRM instance URL?'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                autofillHints: const [AutofillHints.url],
                decoration: const InputDecoration(
                  labelText: 'Instance URL',
                  hintText: 'e.g. http://localhost:3000',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter a valid URL';
                  }
                  if (!Uri.parse(val).isAbsolute) {
                    return 'URL must start with http:// or https://';
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: (_isNextLoading || _isDemoLoading)
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isNextLoading = true);
                          try {
                            final storage = ref.read(storageServiceProvider);
                            // Rimuovi slash finale
                            var url = _controller.text.trim();
                            if (url.endsWith('/')) {
                              url = url.substring(0, url.length - 1);
                            }

                            // URL is format-validated by the TextFormField.
                            // Full connection validation (URL + Token) happens in the next screen.

                            await storage.write(
                              key: 'instance_url',
                              value: url,
                            );
                            await storage.delete(key: 'is_demo_mode');
                            if (mounted) {
                              context.push('/onboarding/method');
                              await _trackServerConnection(url, isDemo: false);
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isNextLoading = false);
                            }
                          }
                        }
                      },
                child: _isNextLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Next'),
              ),
              const SizedBox(height: 24),
            ],
          ),
            ),
        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _connectDemo() async {
    setState(() => _isDemoLoading = true);

    try {
      final storage = ref.read(storageServiceProvider);
      await storage.write(key: 'instance_url', value: DemoConfig.instanceUrl);
      await storage.write(key: 'api_token', value: DemoConfig.apiToken);

      await ref
          .read(authStateProvider.notifier)
          .login(DemoConfig.apiToken, isDemo: true);
      ref.invalidate(crmRepositoryProvider);

      // Attempt connection implicitly, by navigating and letting app structure resolve.
      // But we should test it first to show error if it fails
      try {
        final repo = await ref.read(crmRepositoryProvider.future);
        await repo.getCurrentUserName(); // A simple check
        if (mounted) {
          context.go('/home');
          await _trackServerConnection(DemoConfig.instanceUrl, isDemo: true);
        }
      } catch (e) {
        // Test failed
        await storage.delete(key: 'instance_url');
        await storage.delete(key: 'api_token');
        await storage.delete(key: 'is_demo_mode');
        if (mounted) {
          SnackbarHelper.showError(
            context,
            'Demo temporarily unavailable. Please try again later.',
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isDemoLoading = false);
      }
    }
  }
}
