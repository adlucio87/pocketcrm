import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  factory Task({
    required String id,
    required String title,
    String? body,
    bool? completed,
    DateTime? dueAt,
    String? contactId,
    DateTime? createdAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  factory Task.fromTwenty(Map<String, dynamic> json) {
    String? bodyText;
    final bodyV2 = json['bodyV2'];
    if (bodyV2 is Map) {
      final blocknote = bodyV2['blocknote'];
      final blockEditor = bodyV2['blockEditor'];
      if (blocknote is String) {
        bodyText = blocknote;
      } else if (blocknote is Map && blocknote['text'] != null) {
        bodyText = blocknote['text'];
      } else if (blockEditor is Map && blockEditor['text'] != null) {
        bodyText = blockEditor['text'];
      } else if (bodyV2['text'] != null) {
        bodyText = bodyV2['text'];
      }
    }

    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      body: bodyText,
      completed: json['status'] == 'DONE',
      dueAt: json['dueAt'] != null ? DateTime.parse(json['dueAt']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
