// Schermata di review con campi pre-compilati editabili
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import 'scan_provider.dart';

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
    final data = ref.read(scanNotifierProvider).parsedData;
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

    // Mostra loading se ancora in elaborazione
    if (scanState.status == ScanStatus.processing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analisi biglietto in corso...'),
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
              Text(scanState.errorMessage ?? 'Errore sconosciuto'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Riprova'),
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
        title: const Text('Verifica dati'),
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
                  const Text('CONTATTO',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        letterSpacing: 1.2, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _Field('Nome', _firstName, Icons.person)),
                    const SizedBox(width: 12),
                    Expanded(child: _Field('Cognome', _lastName, null)),
                  ]),
                  const SizedBox(height: 12),
                  _Field('Email', _email, Icons.email),
                  const SizedBox(height: 12),
                  _Field('Telefono', _phone, Icons.phone),
                  const SizedBox(height: 24),
                  const Text('AZIENDA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        letterSpacing: 1.2, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _Field('Azienda', _company, Icons.business),
                  const SizedBox(height: 12),
                  _Field('Ruolo', _jobTitle, Icons.work_outline),
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
                  : const Text('Crea Contatto'),
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
    if (_firstName.text.trim().isEmpty && _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci almeno nome o email')),
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
            content: Text('✅ Contatto creato con successo'),
            backgroundColor: Colors.green,
          ),
        );
        // Naviga al dettaglio del contatto appena creato
        context.go('/contacts/${contact.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
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
        ? '✅ Lettura ottima — verifica i dati'
        : confidence >= 0.4
            ? '⚠️ Lettura parziale — controlla i campi'
            : '❌ Lettura difficile — compila manualmente';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withOpacity(0.1),
      child: Text(message,
        style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13)),
    );
  }
}