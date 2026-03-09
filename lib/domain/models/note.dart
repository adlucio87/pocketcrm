import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
class Note with _$Note {
  factory Note({
    required String id,
    required String body,
    String? contactId,
    String? companyId,
    DateTime? createdAt,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  factory Note.fromTwenty(Map<String, dynamic> json) {
    String? bodyText = '';
    final bodyV2 = json['bodyV2'];
    if (bodyV2 is Map) {
      if (bodyV2['blocknote'] is String) {
        bodyText = bodyV2['blocknote'];
      } else if (bodyV2['blocknote'] is Map) {
        bodyText = bodyV2['blocknote']['text'];
      } else if (bodyV2['blockEditor'] is Map) {
        bodyText = bodyV2['blockEditor']['text'];
      }
    } else if (json['body'] is String) {
      bodyText = json['body'];
    }

    return Note(
      id: json['id'],
      body: bodyText ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
