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
  String get token => throw _privateConstructorUsedError;
  Map<String, dynamic> get user_settings => throw _privateConstructorUsedError;

  /// Serializes this AuthSuccess to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthSuccess
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthSuccessCopyWith<AuthSuccess> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthSuccessCopyWith<$Res> {
  factory $AuthSuccessCopyWith(
          AuthSuccess value, $Res Function(AuthSuccess) then) =
      _$AuthSuccessCopyWithImpl<$Res, AuthSuccess>;
  @useResult
  $Res call({String token, Map<String, dynamic> user_settings});
}

/// @nodoc
class _$AuthSuccessCopyWithImpl<$Res, $Val extends AuthSuccess>
    implements $AuthSuccessCopyWith<$Res> {
  _$AuthSuccessCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthSuccess
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? user_settings = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      user_settings: null == user_settings
          ? _value.user_settings
          : user_settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
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
  $Res call({String token, Map<String, dynamic> user_settings});
}

/// @nodoc
class __$$AuthSuccessImplCopyWithImpl<$Res>
    extends _$AuthSuccessCopyWithImpl<$Res, _$AuthSuccessImpl>
    implements _$$AuthSuccessImplCopyWith<$Res> {
  __$$AuthSuccessImplCopyWithImpl(
      _$AuthSuccessImpl _value, $Res Function(_$AuthSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthSuccess
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? user_settings = null,
  }) {
    return _then(_$AuthSuccessImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      user_settings: null == user_settings
          ? _value._user_settings
          : user_settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthSuccessImpl implements _AuthSuccess {
  _$AuthSuccessImpl(
      {required this.token, required final Map<String, dynamic> user_settings})
      : _user_settings = user_settings;

  factory _$AuthSuccessImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthSuccessImplFromJson(json);

  @override
  final String token;
  final Map<String, dynamic> _user_settings;
  @override
  Map<String, dynamic> get user_settings {
    if (_user_settings is EqualUnmodifiableMapView) return _user_settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_user_settings);
  }

  @override
  String toString() {
    return 'AuthSuccess(token: $token, user_settings: $user_settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthSuccessImpl &&
            (identical(other.token, token) || other.token == token) &&
            const DeepCollectionEquality()
                .equals(other._user_settings, _user_settings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, token, const DeepCollectionEquality().hash(_user_settings));

  /// Create a copy of AuthSuccess
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      {required final String token,
      required final Map<String, dynamic> user_settings}) = _$AuthSuccessImpl;

  factory _AuthSuccess.fromJson(Map<String, dynamic> json) =
      _$AuthSuccessImpl.fromJson;

  @override
  String get token;
  @override
  Map<String, dynamic> get user_settings;

  /// Create a copy of AuthSuccess
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthSuccessImplCopyWith<_$AuthSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MFARequired _$MFARequiredFromJson(Map<String, dynamic> json) {
  return _MFARequired.fromJson(json);
}

/// @nodoc
mixin _$MFARequired {
  String get user_id => throw _privateConstructorUsedError;
  bool get mfa => throw _privateConstructorUsedError;
  String get ticket => throw _privateConstructorUsedError;
  bool? get sms => throw _privateConstructorUsedError;
  bool? get backup => throw _privateConstructorUsedError;
  bool? get totp => throw _privateConstructorUsedError;
  dynamic get webauthn => throw _privateConstructorUsedError;

  /// Serializes this MFARequired to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MFARequired
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MFARequiredCopyWith<MFARequired> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MFARequiredCopyWith<$Res> {
  factory $MFARequiredCopyWith(
          MFARequired value, $Res Function(MFARequired) then) =
      _$MFARequiredCopyWithImpl<$Res, MFARequired>;
  @useResult
  $Res call(
      {String user_id,
      bool mfa,
      String ticket,
      bool? sms,
      bool? backup,
      bool? totp,
      dynamic webauthn});
}

/// @nodoc
class _$MFARequiredCopyWithImpl<$Res, $Val extends MFARequired>
    implements $MFARequiredCopyWith<$Res> {
  _$MFARequiredCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MFARequired
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? mfa = null,
    Object? ticket = null,
    Object? sms = freezed,
    Object? backup = freezed,
    Object? totp = freezed,
    Object? webauthn = freezed,
  }) {
    return _then(_value.copyWith(
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      mfa: null == mfa
          ? _value.mfa
          : mfa // ignore: cast_nullable_to_non_nullable
              as bool,
      ticket: null == ticket
          ? _value.ticket
          : ticket // ignore: cast_nullable_to_non_nullable
              as String,
      sms: freezed == sms
          ? _value.sms
          : sms // ignore: cast_nullable_to_non_nullable
              as bool?,
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
abstract class _$$MFARequiredImplCopyWith<$Res>
    implements $MFARequiredCopyWith<$Res> {
  factory _$$MFARequiredImplCopyWith(
          _$MFARequiredImpl value, $Res Function(_$MFARequiredImpl) then) =
      __$$MFARequiredImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String user_id,
      bool mfa,
      String ticket,
      bool? sms,
      bool? backup,
      bool? totp,
      dynamic webauthn});
}

/// @nodoc
class __$$MFARequiredImplCopyWithImpl<$Res>
    extends _$MFARequiredCopyWithImpl<$Res, _$MFARequiredImpl>
    implements _$$MFARequiredImplCopyWith<$Res> {
  __$$MFARequiredImplCopyWithImpl(
      _$MFARequiredImpl _value, $Res Function(_$MFARequiredImpl) _then)
      : super(_value, _then);

  /// Create a copy of MFARequired
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? mfa = null,
    Object? ticket = null,
    Object? sms = freezed,
    Object? backup = freezed,
    Object? totp = freezed,
    Object? webauthn = freezed,
  }) {
    return _then(_$MFARequiredImpl(
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      mfa: null == mfa
          ? _value.mfa
          : mfa // ignore: cast_nullable_to_non_nullable
              as bool,
      ticket: null == ticket
          ? _value.ticket
          : ticket // ignore: cast_nullable_to_non_nullable
              as String,
      sms: freezed == sms
          ? _value.sms
          : sms // ignore: cast_nullable_to_non_nullable
              as bool?,
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
class _$MFARequiredImpl implements _MFARequired {
  _$MFARequiredImpl(
      {required this.user_id,
      required this.mfa,
      required this.ticket,
      this.sms,
      this.backup,
      this.totp,
      this.webauthn});

  factory _$MFARequiredImpl.fromJson(Map<String, dynamic> json) =>
      _$$MFARequiredImplFromJson(json);

  @override
  final String user_id;
  @override
  final bool mfa;
  @override
  final String ticket;
  @override
  final bool? sms;
  @override
  final bool? backup;
  @override
  final bool? totp;
  @override
  final dynamic webauthn;

  @override
  String toString() {
    return 'MFARequired(user_id: $user_id, mfa: $mfa, ticket: $ticket, sms: $sms, backup: $backup, totp: $totp, webauthn: $webauthn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MFARequiredImpl &&
            (identical(other.user_id, user_id) || other.user_id == user_id) &&
            (identical(other.mfa, mfa) || other.mfa == mfa) &&
            (identical(other.ticket, ticket) || other.ticket == ticket) &&
            (identical(other.sms, sms) || other.sms == sms) &&
            (identical(other.backup, backup) || other.backup == backup) &&
            (identical(other.totp, totp) || other.totp == totp) &&
            const DeepCollectionEquality().equals(other.webauthn, webauthn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user_id, mfa, ticket, sms,
      backup, totp, const DeepCollectionEquality().hash(webauthn));

  /// Create a copy of MFARequired
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MFARequiredImplCopyWith<_$MFARequiredImpl> get copyWith =>
      __$$MFARequiredImplCopyWithImpl<_$MFARequiredImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MFARequiredImplToJson(
      this,
    );
  }
}

abstract class _MFARequired implements MFARequired {
  factory _MFARequired(
      {required final String user_id,
      required final bool mfa,
      required final String ticket,
      final bool? sms,
      final bool? backup,
      final bool? totp,
      final dynamic webauthn}) = _$MFARequiredImpl;

  factory _MFARequired.fromJson(Map<String, dynamic> json) =
      _$MFARequiredImpl.fromJson;

  @override
  String get user_id;
  @override
  bool get mfa;
  @override
  String get ticket;
  @override
  bool? get sms;
  @override
  bool? get backup;
  @override
  bool? get totp;
  @override
  dynamic get webauthn;

  /// Create a copy of MFARequired
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MFARequiredImplCopyWith<_$MFARequiredImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CaptchaResponse _$CaptchaResponseFromJson(Map<String, dynamic> json) {
  return _CaptchaResponse.fromJson(json);
}

/// @nodoc
mixin _$CaptchaResponse {
  List<dynamic> get captcha_key => throw _privateConstructorUsedError;
  String get captcha_sitekey => throw _privateConstructorUsedError;
  String get captcha_service => throw _privateConstructorUsedError;

  /// Serializes this CaptchaResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CaptchaResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      {List<dynamic> captcha_key,
      String captcha_sitekey,
      String captcha_service});
}

/// @nodoc
class _$CaptchaResponseCopyWithImpl<$Res, $Val extends CaptchaResponse>
    implements $CaptchaResponseCopyWith<$Res> {
  _$CaptchaResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaptchaResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? captcha_key = null,
    Object? captcha_sitekey = null,
    Object? captcha_service = null,
  }) {
    return _then(_value.copyWith(
      captcha_key: null == captcha_key
          ? _value.captcha_key
          : captcha_key // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      captcha_sitekey: null == captcha_sitekey
          ? _value.captcha_sitekey
          : captcha_sitekey // ignore: cast_nullable_to_non_nullable
              as String,
      captcha_service: null == captcha_service
          ? _value.captcha_service
          : captcha_service // ignore: cast_nullable_to_non_nullable
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
      {List<dynamic> captcha_key,
      String captcha_sitekey,
      String captcha_service});
}

/// @nodoc
class __$$CaptchaResponseImplCopyWithImpl<$Res>
    extends _$CaptchaResponseCopyWithImpl<$Res, _$CaptchaResponseImpl>
    implements _$$CaptchaResponseImplCopyWith<$Res> {
  __$$CaptchaResponseImplCopyWithImpl(
      _$CaptchaResponseImpl _value, $Res Function(_$CaptchaResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of CaptchaResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? captcha_key = null,
    Object? captcha_sitekey = null,
    Object? captcha_service = null,
  }) {
    return _then(_$CaptchaResponseImpl(
      captcha_key: null == captcha_key
          ? _value._captcha_key
          : captcha_key // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      captcha_sitekey: null == captcha_sitekey
          ? _value.captcha_sitekey
          : captcha_sitekey // ignore: cast_nullable_to_non_nullable
              as String,
      captcha_service: null == captcha_service
          ? _value.captcha_service
          : captcha_service // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CaptchaResponseImpl implements _CaptchaResponse {
  _$CaptchaResponseImpl(
      {required final List<dynamic> captcha_key,
      required this.captcha_sitekey,
      required this.captcha_service})
      : _captcha_key = captcha_key;

  factory _$CaptchaResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CaptchaResponseImplFromJson(json);

  final List<dynamic> _captcha_key;
  @override
  List<dynamic> get captcha_key {
    if (_captcha_key is EqualUnmodifiableListView) return _captcha_key;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_captcha_key);
  }

  @override
  final String captcha_sitekey;
  @override
  final String captcha_service;

  @override
  String toString() {
    return 'CaptchaResponse(captcha_key: $captcha_key, captcha_sitekey: $captcha_sitekey, captcha_service: $captcha_service)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaptchaResponseImpl &&
            const DeepCollectionEquality()
                .equals(other._captcha_key, _captcha_key) &&
            (identical(other.captcha_sitekey, captcha_sitekey) ||
                other.captcha_sitekey == captcha_sitekey) &&
            (identical(other.captcha_service, captcha_service) ||
                other.captcha_service == captcha_service));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_captcha_key),
      captcha_sitekey,
      captcha_service);

  /// Create a copy of CaptchaResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      {required final List<dynamic> captcha_key,
      required final String captcha_sitekey,
      required final String captcha_service}) = _$CaptchaResponseImpl;

  factory _CaptchaResponse.fromJson(Map<String, dynamic> json) =
      _$CaptchaResponseImpl.fromJson;

  @override
  List<dynamic> get captcha_key;
  @override
  String get captcha_sitekey;
  @override
  String get captcha_service;

  /// Create a copy of CaptchaResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaptchaResponseImplCopyWith<_$CaptchaResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
