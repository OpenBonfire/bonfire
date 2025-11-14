// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'added_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AddedAccount _$AddedAccountFromJson(Map<String, dynamic> json) {
  return _AddedAccount.fromJson(json);
}

/// @nodoc
mixin _$AddedAccount {
  String get token => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get avatar => throw _privateConstructorUsedError;

  /// Serializes this AddedAccount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AddedAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddedAccountCopyWith<AddedAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddedAccountCopyWith<$Res> {
  factory $AddedAccountCopyWith(
          AddedAccount value, $Res Function(AddedAccount) then) =
      _$AddedAccountCopyWithImpl<$Res, AddedAccount>;
  @useResult
  $Res call({String token, String username, String userId, String avatar});
}

/// @nodoc
class _$AddedAccountCopyWithImpl<$Res, $Val extends AddedAccount>
    implements $AddedAccountCopyWith<$Res> {
  _$AddedAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddedAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? username = null,
    Object? userId = null,
    Object? avatar = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AddedAccountImplCopyWith<$Res>
    implements $AddedAccountCopyWith<$Res> {
  factory _$$AddedAccountImplCopyWith(
          _$AddedAccountImpl value, $Res Function(_$AddedAccountImpl) then) =
      __$$AddedAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, String username, String userId, String avatar});
}

/// @nodoc
class __$$AddedAccountImplCopyWithImpl<$Res>
    extends _$AddedAccountCopyWithImpl<$Res, _$AddedAccountImpl>
    implements _$$AddedAccountImplCopyWith<$Res> {
  __$$AddedAccountImplCopyWithImpl(
      _$AddedAccountImpl _value, $Res Function(_$AddedAccountImpl) _then)
      : super(_value, _then);

  /// Create a copy of AddedAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? username = null,
    Object? userId = null,
    Object? avatar = null,
  }) {
    return _then(_$AddedAccountImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AddedAccountImpl implements _AddedAccount {
  _$AddedAccountImpl(
      {required this.token,
      required this.username,
      required this.userId,
      required this.avatar});

  factory _$AddedAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddedAccountImplFromJson(json);

  @override
  final String token;
  @override
  final String username;
  @override
  final String userId;
  @override
  final String avatar;

  @override
  String toString() {
    return 'AddedAccount(token: $token, username: $username, userId: $userId, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddedAccountImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.avatar, avatar) || other.avatar == avatar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, username, userId, avatar);

  /// Create a copy of AddedAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddedAccountImplCopyWith<_$AddedAccountImpl> get copyWith =>
      __$$AddedAccountImplCopyWithImpl<_$AddedAccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddedAccountImplToJson(
      this,
    );
  }
}

abstract class _AddedAccount implements AddedAccount {
  factory _AddedAccount(
      {required final String token,
      required final String username,
      required final String userId,
      required final String avatar}) = _$AddedAccountImpl;

  factory _AddedAccount.fromJson(Map<String, dynamic> json) =
      _$AddedAccountImpl.fromJson;

  @override
  String get token;
  @override
  String get username;
  @override
  String get userId;
  @override
  String get avatar;

  /// Create a copy of AddedAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddedAccountImplCopyWith<_$AddedAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
