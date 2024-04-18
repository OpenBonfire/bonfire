// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthSuccess _$AuthSuccessFromJson(Map<String, dynamic> json) {
  return _AuthSuccess.fromJson(json);
}

/// @nodoc
mixin _$AuthSuccess {
  String get userId => throw _privateConstructorUsedError;
  bool get mfa => throw _privateConstructorUsedError;
  bool? get sms => throw _privateConstructorUsedError;
  String? get ticket => throw _privateConstructorUsedError;
  String? get token => throw _privateConstructorUsedError;
  bool? get backup => throw _privateConstructorUsedError;
  bool? get totp => throw _privateConstructorUsedError;
  dynamic get webauthn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthSuccessCopyWith<AuthSuccess> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthSuccessCopyWith<$Res> {
  factory $AuthSuccessCopyWith(
          AuthSuccess value, $Res Function(AuthSuccess) then) =
      _$AuthSuccessCopyWithImpl<$Res, AuthSuccess>;
  @useResult
  $Res call(
      {String userId,
      bool mfa,
      bool? sms,
      String? ticket,
      String? token,
      bool? backup,
      bool? totp,
      dynamic webauthn});
}

/// @nodoc
class _$AuthSuccessCopyWithImpl<$Res, $Val extends AuthSuccess>
    implements $AuthSuccessCopyWith<$Res> {
  _$AuthSuccessCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? mfa = null,
    Object? sms = freezed,
    Object? ticket = freezed,
    Object? token = freezed,
    Object? backup = freezed,
    Object? totp = freezed,
    Object? webauthn = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      mfa: null == mfa
          ? _value.mfa
          : mfa // ignore: cast_nullable_to_non_nullable
              as bool,
      sms: freezed == sms
          ? _value.sms
          : sms // ignore: cast_nullable_to_non_nullable
              as bool?,
      ticket: freezed == ticket
          ? _value.ticket
          : ticket // ignore: cast_nullable_to_non_nullable
              as String?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      backup: freezed == backup
          ? _value.backup
          : backup // ignore: cast_nullable_to_non_nullable
              as bool?,
      totp: freezed == totp
          ? _value.totp
          : totp // ignore: cast_nullable_to_non_nullable
              as bool?,
      webauthn: freezed == webauthn
          ? _value.webauthn
          : webauthn // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthSuccessImplCopyWith<$Res>
    implements $AuthSuccessCopyWith<$Res> {
  factory _$$AuthSuccessImplCopyWith(
          _$AuthSuccessImpl value, $Res Function(_$AuthSuccessImpl) then) =
      __$$AuthSuccessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      bool mfa,
      bool? sms,
      String? ticket,
      String? token,
      bool? backup,
      bool? totp,
      dynamic webauthn});
}

/// @nodoc
class __$$AuthSuccessImplCopyWithImpl<$Res>
    extends _$AuthSuccessCopyWithImpl<$Res, _$AuthSuccessImpl>
    implements _$$AuthSuccessImplCopyWith<$Res> {
  __$$AuthSuccessImplCopyWithImpl(
      _$AuthSuccessImpl _value, $Res Function(_$AuthSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? mfa = null,
    Object? sms = freezed,
    Object? ticket = freezed,
    Object? token = freezed,
    Object? backup = freezed,
    Object? totp = freezed,
    Object? webauthn = freezed,
  }) {
    return _then(_$AuthSuccessImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      mfa: null == mfa
          ? _value.mfa
          : mfa // ignore: cast_nullable_to_non_nullable
              as bool,
      sms: freezed == sms
          ? _value.sms
          : sms // ignore: cast_nullable_to_non_nullable
              as bool?,
      ticket: freezed == ticket
          ? _value.ticket
          : ticket // ignore: cast_nullable_to_non_nullable
              as String?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      backup: freezed == backup
          ? _value.backup
          : backup // ignore: cast_nullable_to_non_nullable
              as bool?,
      totp: freezed == totp
          ? _value.totp
          : totp // ignore: cast_nullable_to_non_nullable
              as bool?,
      webauthn: freezed == webauthn
          ? _value.webauthn
          : webauthn // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthSuccessImpl implements _AuthSuccess {
  _$AuthSuccessImpl(
      {required this.userId,
      required this.mfa,
      this.sms,
      this.ticket,
      this.token,
      this.backup,
      this.totp,
      this.webauthn});

  factory _$AuthSuccessImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthSuccessImplFromJson(json);

  @override
  final String userId;
  @override
  final bool mfa;
  @override
  final bool? sms;
  @override
  final String? ticket;
  @override
  final String? token;
  @override
  final bool? backup;
  @override
  final bool? totp;
  @override
  final dynamic webauthn;

  @override
  String toString() {
    return 'AuthSuccess(userId: $userId, mfa: $mfa, sms: $sms, ticket: $ticket, token: $token, backup: $backup, totp: $totp, webauthn: $webauthn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthSuccessImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.mfa, mfa) || other.mfa == mfa) &&
            (identical(other.sms, sms) || other.sms == sms) &&
            (identical(other.ticket, ticket) || other.ticket == ticket) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.backup, backup) || other.backup == backup) &&
            (identical(other.totp, totp) || other.totp == totp) &&
            const DeepCollectionEquality().equals(other.webauthn, webauthn));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, mfa, sms, ticket, token,
      backup, totp, const DeepCollectionEquality().hash(webauthn));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthSuccessImplCopyWith<_$AuthSuccessImpl> get copyWith =>
      __$$AuthSuccessImplCopyWithImpl<_$AuthSuccessImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthSuccessImplToJson(
      this,
    );
  }
}

abstract class _AuthSuccess implements AuthSuccess {
  factory _AuthSuccess(
      {required final String userId,
      required final bool mfa,
      final bool? sms,
      final String? ticket,
      final String? token,
      final bool? backup,
      final bool? totp,
      final dynamic webauthn}) = _$AuthSuccessImpl;

  factory _AuthSuccess.fromJson(Map<String, dynamic> json) =
      _$AuthSuccessImpl.fromJson;

  @override
  String get userId;
  @override
  bool get mfa;
  @override
  bool? get sms;
  @override
  String? get ticket;
  @override
  String? get token;
  @override
  bool? get backup;
  @override
  bool? get totp;
  @override
  dynamic get webauthn;
  @override
  @JsonKey(ignore: true)
  _$$AuthSuccessImplCopyWith<_$AuthSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CaptchaResponse _$CaptchaResponseFromJson(Map<String, dynamic> json) {
  return _CaptchaResponse.fromJson(json);
}

/// @nodoc
mixin _$CaptchaResponse {
  List<dynamic> get captchaKey => throw _privateConstructorUsedError;
  String get captchaSitekey => throw _privateConstructorUsedError;
  String get captchaService => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CaptchaResponseCopyWith<CaptchaResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaptchaResponseCopyWith<$Res> {
  factory $CaptchaResponseCopyWith(
          CaptchaResponse value, $Res Function(CaptchaResponse) then) =
      _$CaptchaResponseCopyWithImpl<$Res, CaptchaResponse>;
  @useResult
  $Res call(
      {List<dynamic> captchaKey, String captchaSitekey, String captchaService});
}

/// @nodoc
class _$CaptchaResponseCopyWithImpl<$Res, $Val extends CaptchaResponse>
    implements $CaptchaResponseCopyWith<$Res> {
  _$CaptchaResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? captchaKey = null,
    Object? captchaSitekey = null,
    Object? captchaService = null,
  }) {
    return _then(_value.copyWith(
      captchaKey: null == captchaKey
          ? _value.captchaKey
          : captchaKey // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      captchaSitekey: null == captchaSitekey
          ? _value.captchaSitekey
          : captchaSitekey // ignore: cast_nullable_to_non_nullable
              as String,
      captchaService: null == captchaService
          ? _value.captchaService
          : captchaService // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CaptchaResponseImplCopyWith<$Res>
    implements $CaptchaResponseCopyWith<$Res> {
  factory _$$CaptchaResponseImplCopyWith(_$CaptchaResponseImpl value,
          $Res Function(_$CaptchaResponseImpl) then) =
      __$$CaptchaResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<dynamic> captchaKey, String captchaSitekey, String captchaService});
}

/// @nodoc
class __$$CaptchaResponseImplCopyWithImpl<$Res>
    extends _$CaptchaResponseCopyWithImpl<$Res, _$CaptchaResponseImpl>
    implements _$$CaptchaResponseImplCopyWith<$Res> {
  __$$CaptchaResponseImplCopyWithImpl(
      _$CaptchaResponseImpl _value, $Res Function(_$CaptchaResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? captchaKey = null,
    Object? captchaSitekey = null,
    Object? captchaService = null,
  }) {
    return _then(_$CaptchaResponseImpl(
      captchaKey: null == captchaKey
          ? _value._captchaKey
          : captchaKey // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      captchaSitekey: null == captchaSitekey
          ? _value.captchaSitekey
          : captchaSitekey // ignore: cast_nullable_to_non_nullable
              as String,
      captchaService: null == captchaService
          ? _value.captchaService
          : captchaService // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CaptchaResponseImpl implements _CaptchaResponse {
  _$CaptchaResponseImpl(
      {required final List<dynamic> captchaKey,
      required this.captchaSitekey,
      required this.captchaService})
      : _captchaKey = captchaKey;

  factory _$CaptchaResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CaptchaResponseImplFromJson(json);

  final List<dynamic> _captchaKey;
  @override
  List<dynamic> get captchaKey {
    if (_captchaKey is EqualUnmodifiableListView) return _captchaKey;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_captchaKey);
  }

  @override
  final String captchaSitekey;
  @override
  final String captchaService;

  @override
  String toString() {
    return 'CaptchaResponse(captchaKey: $captchaKey, captchaSitekey: $captchaSitekey, captchaService: $captchaService)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaptchaResponseImpl &&
            const DeepCollectionEquality()
                .equals(other._captchaKey, _captchaKey) &&
            (identical(other.captchaSitekey, captchaSitekey) ||
                other.captchaSitekey == captchaSitekey) &&
            (identical(other.captchaService, captchaService) ||
                other.captchaService == captchaService));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_captchaKey),
      captchaSitekey,
      captchaService);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CaptchaResponseImplCopyWith<_$CaptchaResponseImpl> get copyWith =>
      __$$CaptchaResponseImplCopyWithImpl<_$CaptchaResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CaptchaResponseImplToJson(
      this,
    );
  }
}

abstract class _CaptchaResponse implements CaptchaResponse {
  factory _CaptchaResponse(
      {required final List<dynamic> captchaKey,
      required final String captchaSitekey,
      required final String captchaService}) = _$CaptchaResponseImpl;

  factory _CaptchaResponse.fromJson(Map<String, dynamic> json) =
      _$CaptchaResponseImpl.fromJson;

  @override
  List<dynamic> get captchaKey;
  @override
  String get captchaSitekey;
  @override
  String get captchaService;
  @override
  @JsonKey(ignore: true)
  _$$CaptchaResponseImplCopyWith<_$CaptchaResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
