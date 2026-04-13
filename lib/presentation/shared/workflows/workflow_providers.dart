import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/domain/models/workflow/workflow.dart';

final workflowProvider = FutureProvider.family<List<Workflow>, String>((ref, objectType) async {
  final repo = await ref.read(crmRepositoryProvider.future);
  return repo.getManualWorkflows(objectType);
});
