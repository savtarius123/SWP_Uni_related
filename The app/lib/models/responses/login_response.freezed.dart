// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) {
  return _$LoginResponseImpl.fromJson(json);
}

/// @nodoc
mixin _$LoginResponse {
  String get token => throw _privateConstructorUsedError;
  String get refresh => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;

  /// Serializes this LoginResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginResponseCopyWith<LoginResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseCopyWith<$Res> {
  factory $LoginResponseCopyWith(
          LoginResponse value, $Res Function(LoginResponse) then) =
      _$LoginResponseCopyWithImpl<$Res, LoginResponse>;
  @useResult
  $Res call({String token, String refresh, int userId});
}

/// @nodoc
class _$LoginResponseCopyWithImpl<$Res, $Val extends LoginResponse>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? refresh = null,
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      refresh: null == refresh
          ? _value.refresh
          : refresh // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$$LoginResponseImplImplCopyWith<$Res>
    implements $LoginResponseCopyWith<$Res> {
  factory _$$$LoginResponseImplImplCopyWith(_$$LoginResponseImplImpl value,
          $Res Function(_$$LoginResponseImplImpl) then) =
      __$$$LoginResponseImplImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, String refresh, int userId});
}

/// @nodoc
class __$$$LoginResponseImplImplCopyWithImpl<$Res>
    extends _$LoginResponseCopyWithImpl<$Res, _$$LoginResponseImplImpl>
    implements _$$$LoginResponseImplImplCopyWith<$Res> {
  __$$$LoginResponseImplImplCopyWithImpl(_$$LoginResponseImplImpl _value,
      $Res Function(_$$LoginResponseImplImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? refresh = null,
    Object? userId = null,
  }) {
    return _then(_$$LoginResponseImplImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      refresh: null == refresh
          ? _value.refresh
          : refresh // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$$LoginResponseImplImpl implements _$LoginResponseImpl {
  _$$LoginResponseImplImpl(
      {required this.token, required this.refresh, required this.userId});

  factory _$$LoginResponseImplImpl.fromJson(Map<String, dynamic> json) =>
      _$$$LoginResponseImplImplFromJson(json);

  @override
  final String token;
  @override
  final String refresh;
  @override
  final int userId;

  @override
  String toString() {
    return 'LoginResponse(token: $token, refresh: $refresh, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$$LoginResponseImplImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.refresh, refresh) || other.refresh == refresh) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, refresh, userId);

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$$LoginResponseImplImplCopyWith<_$$LoginResponseImplImpl> get copyWith =>
      __$$$LoginResponseImplImplCopyWithImpl<_$$LoginResponseImplImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$$LoginResponseImplImplToJson(
      this,
    );
  }
}

abstract class _$LoginResponseImpl implements LoginResponse {
  factory _$LoginResponseImpl(
      {required final String token,
      required final String refresh,
      required final int userId}) = _$$LoginResponseImplImpl;

  factory _$LoginResponseImpl.fromJson(Map<String, dynamic> json) =
      _$$LoginResponseImplImpl.fromJson;

  @override
  String get token;
  @override
  String get refresh;
  @override
  int get userId;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$$LoginResponseImplImplCopyWith<_$$LoginResponseImplImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
