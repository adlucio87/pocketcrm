// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkflowInputSchemaImpl _$$WorkflowInputSchemaImplFromJson(
  Map<String, dynamic> json,
) => _$WorkflowInputSchemaImpl(
  fieldName: json['fieldName'] as String,
  fieldType: json['fieldType'] as String,
  isRequired: json['isRequired'] as bool,
);

Map<String, dynamic> _$$WorkflowInputSchemaImplToJson(
  _$WorkflowInputSchemaImpl instance,
) => <String, dynamic>{
  'fieldName': instance.fieldName,
  'fieldType': instance.fieldType,
  'isRequired': instance.isRequired,
};

_$WorkflowImpl _$$WorkflowImplFromJson(Map<String, dynamic> json) =>
    _$WorkflowImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema:
          (json['inputSchema'] as List<dynamic>?)
              ?.map(
                (e) => WorkflowInputSchema.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$WorkflowImplToJson(_$WorkflowImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'inputSchema': instance.inputSchema,
    };
