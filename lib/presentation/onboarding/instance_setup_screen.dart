import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/core/di/providers.dart';

class InstanceSetupScreen extends ConsumerStatefulWidget {
  const InstanceSetupScreen({super.key});

  @override
  ConsumerState<InstanceSetupScreen> createState() =>
      _InstanceSetupScreenState();
}

class _InstanceSetupScreenState extends ConsumerState<InstanceSetupScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadStoredUrl();
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('What is your Twenty CRM instance URL?'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Instance URL',
                  hintText: 'e.g. http://localhost:3000',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'Please enter a valid URL';
                  if (!Uri.parse(val).isAbsolute)
                    return 'URL must start with http:// or https://';
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final storage = ref.read(storageServiceProvider);
                    // Rimuovi slash finale
                    var url = _controller.text.trim();
                    if (url.endsWith('/')) {
                      url = url.substring(0, url.length - 1);
                    }
                    await storage.write(key: 'instance_url', value: url);
                    if (context.mounted) {
                      context.push('/onboarding/token');
                    }
                  }
                },
                child: const Text('Next'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
