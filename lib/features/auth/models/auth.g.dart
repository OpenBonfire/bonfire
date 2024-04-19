// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthSuccessImpl _$$AuthSuccessImplFromJson(Map<String, dynamic> json) =>
    _$AuthSuccessImpl(
      userId: json['userId'] as String,
      mfa: json['mfa'] as bool,
      sms: json['sms'] as bool?,
      ticket: json['ticket'] as String?,
      token: json['token'] as String?,
      backup: json['backup'] as bool?,
      totp: json['totp'] as bool?,
      webauthn: json['webauthn'],
    );

Map<String, dynamic> _$$AuthSuccessImplToJson(_$AuthSuccessImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'mfa': instance.mfa,
      'sms': instance.sms,
      'ticket': instance.ticket,
      'token': instance.token,
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
