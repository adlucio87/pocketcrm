// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TodayData {
  List<Task> get overdueTasks => throw _privateConstructorUsedError;
  List<Task> get todayTasks => throw _privateConstructorUsedError;
  List<Task> get tomorrowTasks => throw _privateConstructorUsedError;
  List<Contact> get recentContacts => throw _privateConstructorUsedError;

  /// Create a copy of TodayData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodayDataCopyWith<TodayData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodayDataCopyWith<$Res> {
  factory $TodayDataCopyWith(TodayData value, $Res Function(TodayData) then) =
      _$TodayDataCopyWithImpl<$Res, TodayData>;
  @useResult
  $Res call({
    List<Task> overdueTasks,
    List<Task> todayTasks,
    List<Task> tomorrowTasks,
    List<Contact> recentContacts,
  });
}

/// @nodoc
class _$TodayDataCopyWithImpl<$Res, $Val extends TodayData>
    implements $TodayDataCopyWith<$Res> {
  _$TodayDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodayData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overdueTasks = null,
    Object? todayTasks = null,
    Object? tomorrowTasks = null,
    Object? recentContacts = null,
  }) {
    return _then(
      _value.copyWith(
            overdueTasks: null == overdueTasks
                ? _value.overdueTasks
                : overdueTasks // ignore: cast_nullable_to_non_nullable
                      as List<Task>,
            todayTasks: null == todayTasks
                ? _value.todayTasks
                : todayTasks // ignore: cast_nullable_to_non_nullable
                      as List<Task>,
            tomorrowTasks: null == tomorrowTasks
                ? _value.tomorrowTasks
                : tomorrowTasks // ignore: cast_nullable_to_non_nullable
                      as List<Task>,
            recentContacts: null == recentContacts
                ? _value.recentContacts
                : recentContacts // ignore: cast_nullable_to_non_nullable
                      as List<Contact>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodayDataImplCopyWith<$Res>
    implements $TodayDataCopyWith<$Res> {
  factory _$$TodayDataImplCopyWith(
    _$TodayDataImpl value,
    $Res Function(_$TodayDataImpl) then,
  ) = __$$TodayDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Task> overdueTasks,
    List<Task> todayTasks,
    List<Task> tomorrowTasks,
    List<Contact> recentContacts,
  });
}

/// @nodoc
class __$$TodayDataImplCopyWithImpl<$Res>
    extends _$TodayDataCopyWithImpl<$Res, _$TodayDataImpl>
    implements _$$TodayDataImplCopyWith<$Res> {
  __$$TodayDataImplCopyWithImpl(
    _$TodayDataImpl _value,
    $Res Function(_$TodayDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodayData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overdueTasks = null,
    Object? todayTasks = null,
    Object? tomorrowTasks = null,
    Object? recentContacts = null,
  }) {
    return _then(
      _$TodayDataImpl(
        overdueTasks: null == overdueTasks
            ? _value._overdueTasks
            : overdueTasks // ignore: cast_nullable_to_non_nullable
                  as List<Task>,
        todayTasks: null == todayTasks
            ? _value._todayTasks
            : todayTasks // ignore: cast_nullable_to_non_nullable
                  as List<Task>,
        tomorrowTasks: null == tomorrowTasks
            ? _value._tomorrowTasks
            : tomorrowTasks // ignore: cast_nullable_to_non_nullable
                  as List<Task>,
        recentContacts: null == recentContacts
            ? _value._recentContacts
            : recentContacts // ignore: cast_nullable_to_non_nullable
                  as List<Contact>,
      ),
    );
  }
}

/// @nodoc

class _$TodayDataImpl implements _TodayData {
  _$TodayDataImpl({
    required final List<Task> overdueTasks,
    required final List<Task> todayTasks,
    required final List<Task> tomorrowTasks,
    required final List<Contact> recentContacts,
  }) : _overdueTasks = overdueTasks,
       _todayTasks = todayTasks,
       _tomorrowTasks = tomorrowTasks,
       _recentContacts = recentContacts;

  final List<Task> _overdueTasks;
  @override
  List<Task> get overdueTasks {
    if (_overdueTasks is EqualUnmodifiableListView) return _overdueTasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_overdueTasks);
  }

  final List<Task> _todayTasks;
  @override
  List<Task> get todayTasks {
    if (_todayTasks is EqualUnmodifiableListView) return _todayTasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todayTasks);
  }

  final List<Task> _tomorrowTasks;
  @override
  List<Task> get tomorrowTasks {
    if (_tomorrowTasks is EqualUnmodifiableListView) return _tomorrowTasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tomorrowTasks);
  }

  final List<Contact> _recentContacts;
  @override
  List<Contact> get recentContacts {
    if (_recentContacts is EqualUnmodifiableListView) return _recentContacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentContacts);
  }

  @override
  String toString() {
    return 'TodayData(overdueTasks: $overdueTasks, todayTasks: $todayTasks, tomorrowTasks: $tomorrowTasks, recentContacts: $recentContacts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodayDataImpl &&
            const DeepCollectionEquality().equals(
              other._overdueTasks,
              _overdueTasks,
            ) &&
            const DeepCollectionEquality().equals(
              other._todayTasks,
              _todayTasks,
            ) &&
            const DeepCollectionEquality().equals(
              other._tomorrowTasks,
              _tomorrowTasks,
            ) &&
            const DeepCollectionEquality().equals(
              other._recentContacts,
              _recentContacts,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_overdueTasks),
    const DeepCollectionEquality().hash(_todayTasks),
    const DeepCollectionEquality().hash(_tomorrowTasks),
    const DeepCollectionEquality().hash(_recentContacts),
  );

  /// Create a copy of TodayData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodayDataImplCopyWith<_$TodayDataImpl> get copyWith =>
      __$$TodayDataImplCopyWithImpl<_$TodayDataImpl>(this, _$identity);
}

abstract class _TodayData implements TodayData {
  factory _TodayData({
    required final List<Task> overdueTasks,
    required final List<Task> todayTasks,
    required final List<Task> tomorrowTasks,
    required final List<Contact> recentContacts,
  }) = _$TodayDataImpl;

  @override
  List<Task> get overdueTasks;
  @override
  List<Task> get todayTasks;
  @override
  List<Task> get tomorrowTasks;
  @override
  List<Contact> get recentContacts;

  /// Create a copy of TodayData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodayDataImplCopyWith<_$TodayDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
