// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workflow.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkflowInputSchema _$WorkflowInputSchemaFromJson(Map<String, dynamic> json) {
  return _WorkflowInputSchema.fromJson(json);
}

/// @nodoc
mixin _$WorkflowInputSchema {
  String get fieldName => throw _privateConstructorUsedError;
  String get fieldType => throw _privateConstructorUsedError;
  bool get isRequired => throw _privateConstructorUsedError;

  /// Serializes this WorkflowInputSchema to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkflowInputSchema
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkflowInputSchemaCopyWith<WorkflowInputSchema> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkflowInputSchemaCopyWith<$Res> {
  factory $WorkflowInputSchemaCopyWith(
    WorkflowInputSchema value,
    $Res Function(WorkflowInputSchema) then,
  ) = _$WorkflowInputSchemaCopyWithImpl<$Res, WorkflowInputSchema>;
  @useResult
  $Res call({String fieldName, String fieldType, bool isRequired});
}

/// @nodoc
class _$WorkflowInputSchemaCopyWithImpl<$Res, $Val extends WorkflowInputSchema>
    implements $WorkflowInputSchemaCopyWith<$Res> {
  _$WorkflowInputSchemaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkflowInputSchema
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fieldName = null,
    Object? fieldType = null,
    Object? isRequired = null,
  }) {
    return _then(
      _value.copyWith(
            fieldName: null == fieldName
                ? _value.fieldName
                : fieldName // ignore: cast_nullable_to_non_nullable
                      as String,
            fieldType: null == fieldType
                ? _value.fieldType
                : fieldType // ignore: cast_nullable_to_non_nullable
                      as String,
            isRequired: null == isRequired
                ? _value.isRequired
                : isRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkflowInputSchemaImplCopyWith<$Res>
    implements $WorkflowInputSchemaCopyWith<$Res> {
  factory _$$WorkflowInputSchemaImplCopyWith(
    _$WorkflowInputSchemaImpl value,
    $Res Function(_$WorkflowInputSchemaImpl) then,
  ) = __$$WorkflowInputSchemaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String fieldName, String fieldType, bool isRequired});
}

/// @nodoc
class __$$WorkflowInputSchemaImplCopyWithImpl<$Res>
    extends _$WorkflowInputSchemaCopyWithImpl<$Res, _$WorkflowInputSchemaImpl>
    implements _$$WorkflowInputSchemaImplCopyWith<$Res> {
  __$$WorkflowInputSchemaImplCopyWithImpl(
    _$WorkflowInputSchemaImpl _value,
    $Res Function(_$WorkflowInputSchemaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkflowInputSchema
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fieldName = null,
    Object? fieldType = null,
    Object? isRequired = null,
  }) {
    return _then(
      _$WorkflowInputSchemaImpl(
        fieldName: null == fieldName
            ? _value.fieldName
            : fieldName // ignore: cast_nullable_to_non_nullable
                  as String,
        fieldType: null == fieldType
            ? _value.fieldType
            : fieldType // ignore: cast_nullable_to_non_nullable
                  as String,
        isRequired: null == isRequired
            ? _value.isRequired
            : isRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkflowInputSchemaImpl implements _WorkflowInputSchema {
  _$WorkflowInputSchemaImpl({
    required this.fieldName,
    required this.fieldType,
    required this.isRequired,
  });

  factory _$WorkflowInputSchemaImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkflowInputSchemaImplFromJson(json);

  @override
  final String fieldName;
  @override
  final String fieldType;
  @override
  final bool isRequired;

  @override
  String toString() {
    return 'WorkflowInputSchema(fieldName: $fieldName, fieldType: $fieldType, isRequired: $isRequired)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkflowInputSchemaImpl &&
            (identical(other.fieldName, fieldName) ||
                other.fieldName == fieldName) &&
            (identical(other.fieldType, fieldType) ||
                other.fieldType == fieldType) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, fieldName, fieldType, isRequired);

  /// Create a copy of WorkflowInputSchema
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkflowInputSchemaImplCopyWith<_$WorkflowInputSchemaImpl> get copyWith =>
      __$$WorkflowInputSchemaImplCopyWithImpl<_$WorkflowInputSchemaImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkflowInputSchemaImplToJson(this);
  }
}

abstract class _WorkflowInputSchema implements WorkflowInputSchema {
  factory _WorkflowInputSchema({
    required final String fieldName,
    required final String fieldType,
    required final bool isRequired,
  }) = _$WorkflowInputSchemaImpl;

  factory _WorkflowInputSchema.fromJson(Map<String, dynamic> json) =
      _$WorkflowInputSchemaImpl.fromJson;

  @override
  String get fieldName;
  @override
  String get fieldType;
  @override
  bool get isRequired;

  /// Create a copy of WorkflowInputSchema
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkflowInputSchemaImplCopyWith<_$WorkflowInputSchemaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Workflow _$WorkflowFromJson(Map<String, dynamic> json) {
  return _Workflow.fromJson(json);
}

/// @nodoc
mixin _$Workflow {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<WorkflowInputSchema> get inputSchema =>
      throw _privateConstructorUsedError;

  /// Serializes this Workflow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Workflow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkflowCopyWith<Workflow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkflowCopyWith<$Res> {
  factory $WorkflowCopyWith(Workflow value, $Res Function(Workflow) then) =
      _$WorkflowCopyWithImpl<$Res, Workflow>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    List<WorkflowInputSchema> inputSchema,
  });
}

/// @nodoc
class _$WorkflowCopyWithImpl<$Res, $Val extends Workflow>
    implements $WorkflowCopyWith<$Res> {
  _$WorkflowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Workflow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? inputSchema = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            inputSchema: null == inputSchema
                ? _value.inputSchema
                : inputSchema // ignore: cast_nullable_to_non_nullable
                      as List<WorkflowInputSchema>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkflowImplCopyWith<$Res>
    implements $WorkflowCopyWith<$Res> {
  factory _$$WorkflowImplCopyWith(
    _$WorkflowImpl value,
    $Res Function(_$WorkflowImpl) then,
  ) = __$$WorkflowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    List<WorkflowInputSchema> inputSchema,
  });
}

/// @nodoc
class __$$WorkflowImplCopyWithImpl<$Res>
    extends _$WorkflowCopyWithImpl<$Res, _$WorkflowImpl>
    implements _$$WorkflowImplCopyWith<$Res> {
  __$$WorkflowImplCopyWithImpl(
    _$WorkflowImpl _value,
    $Res Function(_$WorkflowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Workflow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? inputSchema = null,
  }) {
    return _then(
      _$WorkflowImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        inputSchema: null == inputSchema
            ? _value._inputSchema
            : inputSchema // ignore: cast_nullable_to_non_nullable
                  as List<WorkflowInputSchema>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkflowImpl implements _Workflow {
  _$WorkflowImpl({
    required this.id,
    required this.name,
    this.description,
    final List<WorkflowInputSchema> inputSchema = const [],
  }) : _inputSchema = inputSchema;

  factory _$WorkflowImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkflowImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  final List<WorkflowInputSchema> _inputSchema;
  @override
  @JsonKey()
  List<WorkflowInputSchema> get inputSchema {
    if (_inputSchema is EqualUnmodifiableListView) return _inputSchema;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inputSchema);
  }

  @override
  String toString() {
    return 'Workflow(id: $id, name: $name, description: $description, inputSchema: $inputSchema)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkflowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._inputSchema,
              _inputSchema,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    const DeepCollectionEquality().hash(_inputSchema),
  );

  /// Create a copy of Workflow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkflowImplCopyWith<_$WorkflowImpl> get copyWith =>
      __$$WorkflowImplCopyWithImpl<_$WorkflowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkflowImplToJson(this);
  }
}

abstract class _Workflow implements Workflow {
  factory _Workflow({
    required final String id,
    required final String name,
    final String? description,
    final List<WorkflowInputSchema> inputSchema,
  }) = _$WorkflowImpl;

  factory _Workflow.fromJson(Map<String, dynamic> json) =
      _$WorkflowImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  List<WorkflowInputSchema> get inputSchema;

  /// Create a copy of Workflow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkflowImplCopyWith<_$WorkflowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
