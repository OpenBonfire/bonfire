// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthSuccessImpl _$$AuthSuccessImplFromJson(Map<String, dynamic> json) =>
    _$AuthSuccessImpl(
      user_id: json['user_id'] as String,
      mfa: json['mfa'] as bool,
      token: json['token'] as String,
      sms: json['sms'] as bool?,
      backup: json['backup'] as bool?,
      totp: json['totp'] as bool?,
      webauthn: json['webauthn'],
    );

Map<String, dynamic> _$$AuthSuccessImplToJson(_$AuthSuccessImpl instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'mfa': instance.mfa,
      'token': instance.token,
      'sms': instance.sms,
      'backup': instance.backup,
      'totp': instance.totp,
      'webauthn': instance.webauthn,
    };

_$MFARequiredImpl _$$MFARequiredImplFromJson(Map<String, dynamic> json) =>
    _$MFARequiredImpl(
      user_id: json['user_id'] as String,
      mfa: json['mfa'] as bool,
      ticket: json['ticket'] as String,
      sms: json['sms'] as bool?,
      backup: json['backup'] as bool?,
      totp: json['totp'] as bool?,
      webauthn: json['webauthn'],
    );

Map<String, dynamic> _$$MFARequiredImplToJson(_$MFARequiredImpl instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'mfa': instance.mfa,
      'ticket': instance.ticket,
      'sms': instance.sms,
      'backup': instance.backup,
      'totp': instance.totp,
      'webauthn': instance.webauthn,
    };

_$CaptchaResponseImpl _$$CaptchaResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CaptchaResponseImpl(
      captcha_key: json['captcha_key'] as List<dynamic>,
      captcha_sitekey: json['captcha_sitekey'] as String,
      captcha_service: json['captcha_service'] as String,
    );

Map<String, dynamic> _$$CaptchaResponseImplToJson(
        _$CaptchaResponseImpl instance) =>
    <String, dynamic>{
      'captcha_key': instance.captcha_key,
      'captcha_sitekey': instance.captcha_sitekey,
      'captcha_service': instance.captcha_service,
    };
