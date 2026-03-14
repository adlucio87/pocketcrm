// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ScanState {
  ScanStatus get status => throw _privateConstructorUsedError;
  BusinessCardData? get parsedData => throw _privateConstructorUsedError;
  String? get rawText => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ScanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScanStateCopyWith<ScanState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanStateCopyWith<$Res> {
  factory $ScanStateCopyWith(ScanState value, $Res Function(ScanState) then) =
      _$ScanStateCopyWithImpl<$Res, ScanState>;
  @useResult
  $Res call({
    ScanStatus status,
    BusinessCardData? parsedData,
    String? rawText,
    String? errorMessage,
  });
}

/// @nodoc
class _$ScanStateCopyWithImpl<$Res, $Val extends ScanState>
    implements $ScanStateCopyWith<$Res> {
  _$ScanStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? parsedData = freezed,
    Object? rawText = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ScanStatus,
            parsedData: freezed == parsedData
                ? _value.parsedData
                : parsedData // ignore: cast_nullable_to_non_nullable
                      as BusinessCardData?,
            rawText: freezed == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScanStateImplCopyWith<$Res>
    implements $ScanStateCopyWith<$Res> {
  factory _$$ScanStateImplCopyWith(
    _$ScanStateImpl value,
    $Res Function(_$ScanStateImpl) then,
  ) = __$$ScanStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ScanStatus status,
    BusinessCardData? parsedData,
    String? rawText,
    String? errorMessage,
  });
}

/// @nodoc
class __$$ScanStateImplCopyWithImpl<$Res>
    extends _$ScanStateCopyWithImpl<$Res, _$ScanStateImpl>
    implements _$$ScanStateImplCopyWith<$Res> {
  __$$ScanStateImplCopyWithImpl(
    _$ScanStateImpl _value,
    $Res Function(_$ScanStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? parsedData = freezed,
    Object? rawText = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$ScanStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ScanStatus,
        parsedData: freezed == parsedData
            ? _value.parsedData
            : parsedData // ignore: cast_nullable_to_non_nullable
                  as BusinessCardData?,
        rawText: freezed == rawText
            ? _value.rawText
            : rawText // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ScanStateImpl implements _ScanState {
  _$ScanStateImpl({
    this.status = ScanStatus.idle,
    this.parsedData,
    this.rawText,
    this.errorMessage,
  });

  @override
  @JsonKey()
  final ScanStatus status;
  @override
  final BusinessCardData? parsedData;
  @override
  final String? rawText;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ScanState(status: $status, parsedData: $parsedData, rawText: $rawText, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.parsedData, parsedData) ||
                other.parsedData == parsedData) &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, status, parsedData, rawText, errorMessage);

  /// Create a copy of ScanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanStateImplCopyWith<_$ScanStateImpl> get copyWith =>
      __$$ScanStateImplCopyWithImpl<_$ScanStateImpl>(this, _$identity);
}

abstract class _ScanState implements ScanState {
  factory _ScanState({
    final ScanStatus status,
    final BusinessCardData? parsedData,
    final String? rawText,
    final String? errorMessage,
  }) = _$ScanStateImpl;

  @override
  ScanStatus get status;
  @override
  BusinessCardData? get parsedData;
  @override
  String? get rawText;
  @override
  String? get errorMessage;

  /// Create a copy of ScanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScanStateImplCopyWith<_$ScanStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
