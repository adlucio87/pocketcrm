// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Task _$TaskFromJson(Map<String, dynamic> json) {
  return _Task.fromJson(json);
}

/// @nodoc
mixin _$Task {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;
  bool? get completed => throw _privateConstructorUsedError;
  DateTime? get dueAt => throw _privateConstructorUsedError;
  String? get contactId => throw _privateConstructorUsedError;
  String? get contactName => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call({
    String id,
    String title,
    String? body,
    bool? completed,
    DateTime? dueAt,
    String? contactId,
    String? contactName,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = freezed,
    Object? completed = freezed,
    Object? dueAt = freezed,
    Object? contactId = freezed,
    Object? contactName = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: freezed == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String?,
            completed: freezed == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool?,
            dueAt: freezed == dueAt
                ? _value.dueAt
                : dueAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            contactId: freezed == contactId
                ? _value.contactId
                : contactId // ignore: cast_nullable_to_non_nullable
                      as String?,
            contactName: freezed == contactName
                ? _value.contactName
                : contactName // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaskImplCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$TaskImplCopyWith(
    _$TaskImpl value,
    $Res Function(_$TaskImpl) then,
  ) = __$$TaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? body,
    bool? completed,
    DateTime? dueAt,
    String? contactId,
    String? contactName,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$TaskImplCopyWithImpl<$Res>
    extends _$TaskCopyWithImpl<$Res, _$TaskImpl>
    implements _$$TaskImplCopyWith<$Res> {
  __$$TaskImplCopyWithImpl(_$TaskImpl _value, $Res Function(_$TaskImpl) _then)
    : super(_value, _then);

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = freezed,
    Object? completed = freezed,
    Object? dueAt = freezed,
    Object? contactId = freezed,
    Object? contactName = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TaskImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: freezed == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String?,
        completed: freezed == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool?,
        dueAt: freezed == dueAt
            ? _value.dueAt
            : dueAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        contactId: freezed == contactId
            ? _value.contactId
            : contactId // ignore: cast_nullable_to_non_nullable
                  as String?,
        contactName: freezed == contactName
            ? _value.contactName
            : contactName // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskImpl implements _Task {
  _$TaskImpl({
    required this.id,
    required this.title,
    this.body,
    this.completed,
    this.dueAt,
    this.contactId,
    this.contactName,
    this.createdAt,
  });

  factory _$TaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? body;
  @override
  final bool? completed;
  @override
  final DateTime? dueAt;
  @override
  final String? contactId;
  @override
  final String? contactName;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, body: $body, completed: $completed, dueAt: $dueAt, contactId: $contactId, contactName: $contactName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.dueAt, dueAt) || other.dueAt == dueAt) &&
            (identical(other.contactId, contactId) ||
                other.contactId == contactId) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    body,
    completed,
    dueAt,
    contactId,
    contactName,
    createdAt,
  );

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      __$$TaskImplCopyWithImpl<_$TaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskImplToJson(this);
  }
}

abstract class _Task implements Task {
  factory _Task({
    required final String id,
    required final String title,
    final String? body,
    final bool? completed,
    final DateTime? dueAt,
    final String? contactId,
    final String? contactName,
    final DateTime? createdAt,
  }) = _$TaskImpl;

  factory _Task.fromJson(Map<String, dynamic> json) = _$TaskImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get body;
  @override
  bool? get completed;
  @override
  DateTime? get dueAt;
  @override
  String? get contactId;
  @override
  String? get contactName;
  @override
  DateTime? get createdAt;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
