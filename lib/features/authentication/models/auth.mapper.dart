// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'auth.dart';

class AuthNotStartedMapper extends ClassMapperBase<AuthNotStarted> {
  AuthNotStartedMapper._();

  static AuthNotStartedMapper? _instance;
  static AuthNotStartedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AuthNotStartedMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AuthNotStarted';

  @override
  final MappableFields<AuthNotStarted> fields = const {};

  static AuthNotStarted _instantiate(DecodingData data) {
    return AuthNotStarted();
  }

  @override
  final Function instantiate = _instantiate;

  static AuthNotStarted fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AuthNotStarted>(map);
  }

  static AuthNotStarted fromJson(String json) {
    return ensureInitialized().decodeJson<AuthNotStarted>(json);
  }
}

mixin AuthNotStartedMappable {
  String toJson() {
    return AuthNotStartedMapper.ensureInitialized().encodeJson<AuthNotStarted>(
      this as AuthNotStarted,
    );
  }

  Map<String, dynamic> toMap() {
    return AuthNotStartedMapper.ensureInitialized().encodeMap<AuthNotStarted>(
      this as AuthNotStarted,
    );
  }

  AuthNotStartedCopyWith<AuthNotStarted, AuthNotStarted, AuthNotStarted>
  get copyWith => _AuthNotStartedCopyWithImpl<AuthNotStarted, AuthNotStarted>(
    this as AuthNotStarted,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return AuthNotStartedMapper.ensureInitialized().stringifyValue(
      this as AuthNotStarted,
    );
  }

  @override
  bool operator ==(Object other) {
    return AuthNotStartedMapper.ensureInitialized().equalsValue(
      this as AuthNotStarted,
      other,
    );
  }

  @override
  int get hashCode {
    return AuthNotStartedMapper.ensureInitialized().hashValue(
      this as AuthNotStarted,
    );
  }
}

extension AuthNotStartedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AuthNotStarted, $Out> {
  AuthNotStartedCopyWith<$R, AuthNotStarted, $Out> get $asAuthNotStarted =>
      $base.as((v, t, t2) => _AuthNotStartedCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AuthNotStartedCopyWith<$R, $In extends AuthNotStarted, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  AuthNotStartedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AuthNotStartedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AuthNotStarted, $Out>
    implements AuthNotStartedCopyWith<$R, AuthNotStarted, $Out> {
  _AuthNotStartedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AuthNotStarted> $mapper =
      AuthNotStartedMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  AuthNotStarted $make(CopyWithData data) => AuthNotStarted();

  @override
  AuthNotStartedCopyWith<$R2, AuthNotStarted, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AuthNotStartedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AuthSuccessMapper extends ClassMapperBase<AuthSuccess> {
  AuthSuccessMapper._();

  static AuthSuccessMapper? _instance;
  static AuthSuccessMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AuthSuccessMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AuthSuccess';

  static String _$token(AuthSuccess v) => v.token;
  static const Field<AuthSuccess, String> _f$token = Field('token', _$token);
  static Map<String, dynamic> _$user_settings(AuthSuccess v) => v.user_settings;
  static const Field<AuthSuccess, Map<String, dynamic>> _f$user_settings =
      Field('user_settings', _$user_settings);

  @override
  final MappableFields<AuthSuccess> fields = const {
    #token: _f$token,
    #user_settings: _f$user_settings,
  };

  static AuthSuccess _instantiate(DecodingData data) {
    return AuthSuccess(
      token: data.dec(_f$token),
      user_settings: data.dec(_f$user_settings),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AuthSuccess fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AuthSuccess>(map);
  }

  static AuthSuccess fromJson(String json) {
    return ensureInitialized().decodeJson<AuthSuccess>(json);
  }
}

mixin AuthSuccessMappable {
  String toJson() {
    return AuthSuccessMapper.ensureInitialized().encodeJson<AuthSuccess>(
      this as AuthSuccess,
    );
  }

  Map<String, dynamic> toMap() {
    return AuthSuccessMapper.ensureInitialized().encodeMap<AuthSuccess>(
      this as AuthSuccess,
    );
  }

  AuthSuccessCopyWith<AuthSuccess, AuthSuccess, AuthSuccess> get copyWith =>
      _AuthSuccessCopyWithImpl<AuthSuccess, AuthSuccess>(
        this as AuthSuccess,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AuthSuccessMapper.ensureInitialized().stringifyValue(
      this as AuthSuccess,
    );
  }

  @override
  bool operator ==(Object other) {
    return AuthSuccessMapper.ensureInitialized().equalsValue(
      this as AuthSuccess,
      other,
    );
  }

  @override
  int get hashCode {
    return AuthSuccessMapper.ensureInitialized().hashValue(this as AuthSuccess);
  }
}

extension AuthSuccessValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AuthSuccess, $Out> {
  AuthSuccessCopyWith<$R, AuthSuccess, $Out> get $asAuthSuccess =>
      $base.as((v, t, t2) => _AuthSuccessCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AuthSuccessCopyWith<$R, $In extends AuthSuccess, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
  get user_settings;
  $R call({String? token, Map<String, dynamic>? user_settings});
  AuthSuccessCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AuthSuccessCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AuthSuccess, $Out>
    implements AuthSuccessCopyWith<$R, AuthSuccess, $Out> {
  _AuthSuccessCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AuthSuccess> $mapper =
      AuthSuccessMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
  get user_settings => MapCopyWith(
    $value.user_settings,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(user_settings: v),
  );
  @override
  $R call({String? token, Map<String, dynamic>? user_settings}) => $apply(
    FieldCopyWithData({
      if (token != null) #token: token,
      if (user_settings != null) #user_settings: user_settings,
    }),
  );
  @override
  AuthSuccess $make(CopyWithData data) => AuthSuccess(
    token: data.get(#token, or: $value.token),
    user_settings: data.get(#user_settings, or: $value.user_settings),
  );

  @override
  AuthSuccessCopyWith<$R2, AuthSuccess, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AuthSuccessCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MFARequiredMapper extends ClassMapperBase<MFARequired> {
  MFARequiredMapper._();

  static MFARequiredMapper? _instance;
  static MFARequiredMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MFARequiredMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MFARequired';

  static String _$user_id(MFARequired v) => v.user_id;
  static const Field<MFARequired, String> _f$user_id = Field(
    'user_id',
    _$user_id,
  );
  static bool _$mfa(MFARequired v) => v.mfa;
  static const Field<MFARequired, bool> _f$mfa = Field('mfa', _$mfa);
  static String _$ticket(MFARequired v) => v.ticket;
  static const Field<MFARequired, String> _f$ticket = Field('ticket', _$ticket);
  static bool? _$sms(MFARequired v) => v.sms;
  static const Field<MFARequired, bool> _f$sms = Field('sms', _$sms, opt: true);
  static bool? _$backup(MFARequired v) => v.backup;
  static const Field<MFARequired, bool> _f$backup = Field(
    'backup',
    _$backup,
    opt: true,
  );
  static bool? _$totp(MFARequired v) => v.totp;
  static const Field<MFARequired, bool> _f$totp = Field(
    'totp',
    _$totp,
    opt: true,
  );
  static dynamic _$webauthn(MFARequired v) => v.webauthn;
  static const Field<MFARequired, dynamic> _f$webauthn = Field(
    'webauthn',
    _$webauthn,
    opt: true,
  );

  @override
  final MappableFields<MFARequired> fields = const {
    #user_id: _f$user_id,
    #mfa: _f$mfa,
    #ticket: _f$ticket,
    #sms: _f$sms,
    #backup: _f$backup,
    #totp: _f$totp,
    #webauthn: _f$webauthn,
  };

  static MFARequired _instantiate(DecodingData data) {
    return MFARequired(
      user_id: data.dec(_f$user_id),
      mfa: data.dec(_f$mfa),
      ticket: data.dec(_f$ticket),
      sms: data.dec(_f$sms),
      backup: data.dec(_f$backup),
      totp: data.dec(_f$totp),
      webauthn: data.dec(_f$webauthn),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MFARequired fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MFARequired>(map);
  }

  static MFARequired fromJson(String json) {
    return ensureInitialized().decodeJson<MFARequired>(json);
  }
}

mixin MFARequiredMappable {
  String toJson() {
    return MFARequiredMapper.ensureInitialized().encodeJson<MFARequired>(
      this as MFARequired,
    );
  }

  Map<String, dynamic> toMap() {
    return MFARequiredMapper.ensureInitialized().encodeMap<MFARequired>(
      this as MFARequired,
    );
  }

  MFARequiredCopyWith<MFARequired, MFARequired, MFARequired> get copyWith =>
      _MFARequiredCopyWithImpl<MFARequired, MFARequired>(
        this as MFARequired,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MFARequiredMapper.ensureInitialized().stringifyValue(
      this as MFARequired,
    );
  }

  @override
  bool operator ==(Object other) {
    return MFARequiredMapper.ensureInitialized().equalsValue(
      this as MFARequired,
      other,
    );
  }

  @override
  int get hashCode {
    return MFARequiredMapper.ensureInitialized().hashValue(this as MFARequired);
  }
}

extension MFARequiredValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MFARequired, $Out> {
  MFARequiredCopyWith<$R, MFARequired, $Out> get $asMFARequired =>
      $base.as((v, t, t2) => _MFARequiredCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MFARequiredCopyWith<$R, $In extends MFARequired, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? user_id,
    bool? mfa,
    String? ticket,
    bool? sms,
    bool? backup,
    bool? totp,
    dynamic webauthn,
  });
  MFARequiredCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MFARequiredCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MFARequired, $Out>
    implements MFARequiredCopyWith<$R, MFARequired, $Out> {
  _MFARequiredCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MFARequired> $mapper =
      MFARequiredMapper.ensureInitialized();
  @override
  $R call({
    String? user_id,
    bool? mfa,
    String? ticket,
    Object? sms = $none,
    Object? backup = $none,
    Object? totp = $none,
    Object? webauthn = $none,
  }) => $apply(
    FieldCopyWithData({
      if (user_id != null) #user_id: user_id,
      if (mfa != null) #mfa: mfa,
      if (ticket != null) #ticket: ticket,
      if (sms != $none) #sms: sms,
      if (backup != $none) #backup: backup,
      if (totp != $none) #totp: totp,
      if (webauthn != $none) #webauthn: webauthn,
    }),
  );
  @override
  MFARequired $make(CopyWithData data) => MFARequired(
    user_id: data.get(#user_id, or: $value.user_id),
    mfa: data.get(#mfa, or: $value.mfa),
    ticket: data.get(#ticket, or: $value.ticket),
    sms: data.get(#sms, or: $value.sms),
    backup: data.get(#backup, or: $value.backup),
    totp: data.get(#totp, or: $value.totp),
    webauthn: data.get(#webauthn, or: $value.webauthn),
  );

  @override
  MFARequiredCopyWith<$R2, MFARequired, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MFARequiredCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CaptchaResponseMapper extends ClassMapperBase<CaptchaResponse> {
  CaptchaResponseMapper._();

  static CaptchaResponseMapper? _instance;
  static CaptchaResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CaptchaResponseMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CaptchaResponse';

  static const Field<CaptchaResponse, List<dynamic>> _f$captcha_key = Field(
    'captcha_key',
    null,
    mode: FieldMode.param,
  );
  static const Field<CaptchaResponse, String> _f$captcha_sitekey = Field(
    'captcha_sitekey',
    null,
    mode: FieldMode.param,
  );
  static const Field<CaptchaResponse, String> _f$captcha_service = Field(
    'captcha_service',
    null,
    mode: FieldMode.param,
  );

  @override
  final MappableFields<CaptchaResponse> fields = const {
    #captcha_key: _f$captcha_key,
    #captcha_sitekey: _f$captcha_sitekey,
    #captcha_service: _f$captcha_service,
  };

  static CaptchaResponse _instantiate(DecodingData data) {
    return CaptchaResponse(
      captcha_key: data.dec(_f$captcha_key),
      captcha_sitekey: data.dec(_f$captcha_sitekey),
      captcha_service: data.dec(_f$captcha_service),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CaptchaResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CaptchaResponse>(map);
  }

  static CaptchaResponse fromJson(String json) {
    return ensureInitialized().decodeJson<CaptchaResponse>(json);
  }
}

mixin CaptchaResponseMappable {
  String toJson() {
    return CaptchaResponseMapper.ensureInitialized()
        .encodeJson<CaptchaResponse>(this as CaptchaResponse);
  }

  Map<String, dynamic> toMap() {
    return CaptchaResponseMapper.ensureInitialized().encodeMap<CaptchaResponse>(
      this as CaptchaResponse,
    );
  }

  CaptchaResponseCopyWith<CaptchaResponse, CaptchaResponse, CaptchaResponse>
  get copyWith =>
      _CaptchaResponseCopyWithImpl<CaptchaResponse, CaptchaResponse>(
        this as CaptchaResponse,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CaptchaResponseMapper.ensureInitialized().stringifyValue(
      this as CaptchaResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return CaptchaResponseMapper.ensureInitialized().equalsValue(
      this as CaptchaResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return CaptchaResponseMapper.ensureInitialized().hashValue(
      this as CaptchaResponse,
    );
  }
}

extension CaptchaResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CaptchaResponse, $Out> {
  CaptchaResponseCopyWith<$R, CaptchaResponse, $Out> get $asCaptchaResponse =>
      $base.as((v, t, t2) => _CaptchaResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CaptchaResponseCopyWith<$R, $In extends CaptchaResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    required List<dynamic> captcha_key,
    required String captcha_sitekey,
    required String captcha_service,
  });
  CaptchaResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CaptchaResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CaptchaResponse, $Out>
    implements CaptchaResponseCopyWith<$R, CaptchaResponse, $Out> {
  _CaptchaResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CaptchaResponse> $mapper =
      CaptchaResponseMapper.ensureInitialized();
  @override
  $R call({
    required List<dynamic> captcha_key,
    required String captcha_sitekey,
    required String captcha_service,
  }) => $apply(
    FieldCopyWithData({
      #captcha_key: captcha_key,
      #captcha_sitekey: captcha_sitekey,
      #captcha_service: captcha_service,
    }),
  );
  @override
  CaptchaResponse $make(CopyWithData data) => CaptchaResponse(
    captcha_key: data.get(#captcha_key),
    captcha_sitekey: data.get(#captcha_sitekey),
    captcha_service: data.get(#captcha_service),
  );

  @override
  CaptchaResponseCopyWith<$R2, CaptchaResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CaptchaResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

