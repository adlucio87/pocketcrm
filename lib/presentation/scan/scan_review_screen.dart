// Schermata di review con campi pre-compilati editabili
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import 'scan_provider.dart';
import 'package:pocketcrm/core/utils/demo_utils.dart';

class ScanReviewScreen extends ConsumerStatefulWidget {
  const ScanReviewScreen({super.key});

  @override
  ConsumerState<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

class _ScanReviewScreenState extends ConsumerState<ScanReviewScreen> {
  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _company;
  late TextEditingController _jobTitle;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(scanNotifierProvider);
    final data = state.parsedData;
    print('REVIEW: initState - status: ${state.status}, data: $data');
    _firstName = TextEditingController(text: data?.firstName ?? '');
    _lastName = TextEditingController(text: data?.lastName ?? '');
    _email = TextEditingController(text: data?.email ?? '');
    _phone = TextEditingController(text: data?.phone ?? '');
    _company = TextEditingController(text: data?.company ?? '');
    _jobTitle = TextEditingController(text: data?.jobTitle ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanNotifierProvider);
    print('REVIEW: build - status: ${scanState.status}, data: ${scanState.parsedData}');

    // Mostra loading se ancora in elaborazione
    if (scanState.status == ScanStatus.processing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing business card...'),
            ],
          ),
        ),
      );
    }

    // Mostra errore
    if (scanState.status == ScanStatus.error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(scanState.errorMessage ?? 'Unknown error'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Confidence indicator
    final confidence = scanState.parsedData?.confidence ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(scanNotifierProvider.notifier).reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Banner confidenza
          _ConfidenceBanner(confidence: confidence),

          // Form campi editabili
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CONTACT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        letterSpacing: 1.2, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _Field('Name', _firstName, Icons.person)),
                    const SizedBox(width: 12),
                    Expanded(child: _Field('Last Name', _lastName, null)),
                  ]),
                  const SizedBox(height: 12),
                  _Field('Email', _email, Icons.email),
                  const SizedBox(height: 12),
                  _Field('Phone', _phone, Icons.phone),
                  const SizedBox(height: 24),
                  const Text('COMPANY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        letterSpacing: 1.2, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _Field('Company', _company, Icons.business),
                  const SizedBox(height: 12),
                  _Field('Role', _jobTitle, Icons.work_outline),
                ],
              ),
            ),
          ),

          // Bottone salva
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Create Contact'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _Field(String label, TextEditingController ctrl, IconData? icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      ),
    );
  }

  Future<void> _save() async {
    if (!await DemoUtils.checkDemoAction(context, ref)) return;

    if (_firstName.text.trim().isEmpty && _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least name or email')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(crmRepositoryProvider).requireValue;
      final contact = await repo.createContact(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      );

      ref.read(scanNotifierProvider.notifier).reset();
      ref.invalidate(contactsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Contact created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to contact details
        context.go('/contacts/${contact.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _firstName.dispose(); _lastName.dispose();
    _email.dispose(); _phone.dispose();
    _company.dispose(); _jobTitle.dispose();
    super.dispose();
  }
}

// Banner che mostra confidenza del parsing
class _ConfidenceBanner extends StatelessWidget {
  final double confidence;
  const _ConfidenceBanner({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final color = confidence >= 0.7
        ? Colors.green
        : confidence >= 0.4
            ? Colors.orange
            : Colors.red;

    final message = confidence >= 0.7
        ? '✅ Excellent capture — verify data'
        : confidence >= 0.4
            ? '⚠️ Partial capture — check fields'
            : '❌ Difficult to read — fill manually';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withValues(alpha: 0.1),
      child: Text(message,
        style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13)),
    );
  }
}