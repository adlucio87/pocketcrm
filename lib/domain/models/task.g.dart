// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String?,
  completed: json['completed'] as bool?,
  dueAt: json['dueAt'] == null ? null : DateTime.parse(json['dueAt'] as String),
  contactId: json['contactId'] as String?,
  contactName: json['contactName'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'completed': instance.completed,
      'dueAt': instance.dueAt?.toIso8601String(),
      'contactId': instance.contactId,
      'contactName': instance.contactName,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
