import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketcrm/domain/models/workflow/workflow.dart';
import 'package:pocketcrm/presentation/shared/workflows/workflow_providers.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/presentation/shared/workflows/workflow_input_form.dart';
import 'package:pocketcrm/presentation/shared/workflows/slide_to_execute_button.dart';

class WorkflowBottomSheet extends ConsumerStatefulWidget {
  final String recordId;
  final String objectType;

  const WorkflowBottomSheet({
    Key? key,
    required this.recordId,
    required this.objectType,
  }) : super(key: key);

  @override
  ConsumerState<WorkflowBottomSheet> createState() => _WorkflowBottomSheetState();
}

class _WorkflowBottomSheetState extends ConsumerState<WorkflowBottomSheet> {
  Workflow? _selectedWorkflow;
  Map<String, dynamic> _payload = {};
  bool _isFormValid = true;

  @override
  Widget build(BuildContext context) {
    final workflowsAsync = ref.watch(workflowProvider(widget.objectType));

    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedWorkflow == null ? "Workflow Manuali" : _selectedWorkflow!.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: workflowsAsync.when(
                data: (workflows) {
                  if (workflows.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "Nessun workflow manuale disponibile.\nConfigurali dalla web app.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_selectedWorkflow == null) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workflows.length,
                      itemBuilder: (context, index) {
                        final workflow = workflows[index];
                        return ListTile(
                          leading: const Icon(Icons.flash_on),
                          title: Text(workflow.name),
                          subtitle: workflow.description != null ? Text(workflow.description!) : null,
                          onTap: () {
                            // Check for unsupported fields
                            bool hasUnsupportedFields = workflow.inputSchema.any((s) => s.fieldType != 'Text' && s.fieldType != 'String' && s.fieldType != 'Number');
                            if (hasUnsupportedFields) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Questo workflow richiede dati complessi. Avvialo dalla piattaforma web."),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _selectedWorkflow = workflow;
                              _isFormValid = workflow.inputSchema.isEmpty;
                            });
                          },
                        );
                      },
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_selectedWorkflow!.description != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(_selectedWorkflow!.description!),
                        ),
                      WorkflowInputForm(
                        schema: _selectedWorkflow!.inputSchema,
                        onChanged: (payload, isValid) {
                          setState(() {
                            _payload = payload;
                            _isFormValid = isValid;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      SlideToExecuteButton(
                        enabled: _isFormValid,
                        onExecute: () async {
                          final repo = await ref.read(crmRepositoryProvider.future);
final success = await repo.executeManualWorkflow(
                            _selectedWorkflow!.id,
                            widget.recordId,
                            _payload,
                          );

                          if (success) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Workflow avviato con successo!")),
                            );
                            await Future.delayed(const Duration(seconds: 1));
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedWorkflow = null;
                          });
                        },
                        child: const Text("Indietro"),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text("Errore: $error")),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
