import 'package:freezed_annotation/freezed_annotation.dart';

part 'workflow.freezed.dart';
part 'workflow.g.dart';

@freezed
class WorkflowInputSchema with _$WorkflowInputSchema {
  factory WorkflowInputSchema({
    required String fieldName,
    required String fieldType,
    required bool isRequired,
  }) = _WorkflowInputSchema;

  factory WorkflowInputSchema.fromJson(Map<String, dynamic> json) => _$WorkflowInputSchemaFromJson(json);
}

@freezed
class Workflow with _$Workflow {
  factory Workflow({
    required String id,
    required String name,
    String? description,
    @Default([]) List<WorkflowInputSchema> inputSchema,
  }) = _Workflow;

  factory Workflow.fromJson(Map<String, dynamic> json) => _$WorkflowFromJson(json);

  factory Workflow.fromTwenty(Map<String, dynamic> json) {
    return Workflow(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema: (json['inputSchema'] as List<dynamic>?)
              ?.map((e) => WorkflowInputSchema.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
