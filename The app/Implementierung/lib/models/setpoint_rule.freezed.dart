// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'setpoint_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SetpointRanges _$SetpointRangesFromJson(Map<String, dynamic> json) {
  return _SetpointRanges.fromJson(json);
}

/// @nodoc
mixin _$SetpointRanges {
  (double, double) get rangeOk => throw _privateConstructorUsedError;
  (double, double) get rangeAbnormal => throw _privateConstructorUsedError;
  (double, double) get rangeCritical => throw _privateConstructorUsedError;

  /// Serializes this SetpointRanges to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SetpointRanges
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetpointRangesCopyWith<SetpointRanges> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetpointRangesCopyWith<$Res> {
  factory $SetpointRangesCopyWith(
          SetpointRanges value, $Res Function(SetpointRanges) then) =
      _$SetpointRangesCopyWithImpl<$Res, SetpointRanges>;
  @useResult
  $Res call(
      {(double, double) rangeOk,
      (double, double) rangeAbnormal,
      (double, double) rangeCritical});
}

/// @nodoc
class _$SetpointRangesCopyWithImpl<$Res, $Val extends SetpointRanges>
    implements $SetpointRangesCopyWith<$Res> {
  _$SetpointRangesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetpointRanges
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rangeOk = null,
    Object? rangeAbnormal = null,
    Object? rangeCritical = null,
  }) {
    return _then(_value.copyWith(
      rangeOk: null == rangeOk
          ? _value.rangeOk
          : rangeOk // ignore: cast_nullable_to_non_nullable
              as (double, double),
      rangeAbnormal: null == rangeAbnormal
          ? _value.rangeAbnormal
          : rangeAbnormal // ignore: cast_nullable_to_non_nullable
              as (double, double),
      rangeCritical: null == rangeCritical
          ? _value.rangeCritical
          : rangeCritical // ignore: cast_nullable_to_non_nullable
              as (double, double),
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SetpointRangesImplCopyWith<$Res>
    implements $SetpointRangesCopyWith<$Res> {
  factory _$$SetpointRangesImplCopyWith(_$SetpointRangesImpl value,
          $Res Function(_$SetpointRangesImpl) then) =
      __$$SetpointRangesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {(double, double) rangeOk,
      (double, double) rangeAbnormal,
      (double, double) rangeCritical});
}

/// @nodoc
class __$$SetpointRangesImplCopyWithImpl<$Res>
    extends _$SetpointRangesCopyWithImpl<$Res, _$SetpointRangesImpl>
    implements _$$SetpointRangesImplCopyWith<$Res> {
  __$$SetpointRangesImplCopyWithImpl(
      _$SetpointRangesImpl _value, $Res Function(_$SetpointRangesImpl) _then)
      : super(_value, _then);

  /// Create a copy of SetpointRanges
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rangeOk = null,
    Object? rangeAbnormal = null,
    Object? rangeCritical = null,
  }) {
    return _then(_$SetpointRangesImpl(
      rangeOk: null == rangeOk
          ? _value.rangeOk
          : rangeOk // ignore: cast_nullable_to_non_nullable
              as (double, double),
      rangeAbnormal: null == rangeAbnormal
          ? _value.rangeAbnormal
          : rangeAbnormal // ignore: cast_nullable_to_non_nullable
              as (double, double),
      rangeCritical: null == rangeCritical
          ? _value.rangeCritical
          : rangeCritical // ignore: cast_nullable_to_non_nullable
              as (double, double),
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SetpointRangesImpl implements _SetpointRanges {
  const _$SetpointRangesImpl(
      {required this.rangeOk,
      required this.rangeAbnormal,
      required this.rangeCritical});

  factory _$SetpointRangesImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetpointRangesImplFromJson(json);

  @override
  final (double, double) rangeOk;
  @override
  final (double, double) rangeAbnormal;
  @override
  final (double, double) rangeCritical;

  @override
  String toString() {
    return 'SetpointRanges(rangeOk: $rangeOk, rangeAbnormal: $rangeAbnormal, rangeCritical: $rangeCritical)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetpointRangesImpl &&
            (identical(other.rangeOk, rangeOk) || other.rangeOk == rangeOk) &&
            (identical(other.rangeAbnormal, rangeAbnormal) ||
                other.rangeAbnormal == rangeAbnormal) &&
            (identical(other.rangeCritical, rangeCritical) ||
                other.rangeCritical == rangeCritical));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, rangeOk, rangeAbnormal, rangeCritical);

  /// Create a copy of SetpointRanges
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetpointRangesImplCopyWith<_$SetpointRangesImpl> get copyWith =>
      __$$SetpointRangesImplCopyWithImpl<_$SetpointRangesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetpointRangesImplToJson(
      this,
    );
  }
}

abstract class _SetpointRanges implements SetpointRanges {
  const factory _SetpointRanges(
      {required final (double, double) rangeOk,
      required final (double, double) rangeAbnormal,
      required final (double, double) rangeCritical}) = _$SetpointRangesImpl;

  factory _SetpointRanges.fromJson(Map<String, dynamic> json) =
      _$SetpointRangesImpl.fromJson;

  @override
  (double, double) get rangeOk;
  @override
  (double, double) get rangeAbnormal;
  @override
  (double, double) get rangeCritical;

  /// Create a copy of SetpointRanges
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetpointRangesImplCopyWith<_$SetpointRangesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
