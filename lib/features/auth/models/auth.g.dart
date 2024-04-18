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
      captchaKey: json['captchaKey'] as List<dynamic>,
      captchaSitekey: json['captchaSitekey'] as String,
      captchaService: json['captchaService'] as String,
    );

Map<String, dynamic> _$$CaptchaResponseImplToJson(
        _$CaptchaResponseImpl instance) =>
    <String, dynamic>{
      'captchaKey': instance.captchaKey,
      'captchaSitekey': instance.captchaSitekey,
      'captchaService': instance.captchaService,
    };
