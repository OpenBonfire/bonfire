import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.mapper.dart';

abstract class AuthResponse {}

@MappableClass()
class AuthNotStarted extends AuthResponse with AuthNotStartedMappable {}

@MappableClass()
class AuthSuccess extends AuthResponse with AuthSuccessMappable {
  final String token;
  final Map<String, dynamic> user_settings;
  AuthSuccess({required this.token, required this.user_settings});
}

/// MFA required response with [user_id], [mfa], [ticket], [sms], [backup], [totp], and [webauthn]
@MappableClass()
class MFARequired extends AuthResponse with MFARequiredMappable {
  final String user_id;
  final bool mfa;
  final String ticket;
  bool? sms;
  bool? backup;
  bool? totp;
  dynamic webauthn;
  MFARequired({
    required this.user_id,
    required this.mfa,
    required this.ticket,
    this.sms,
    this.backup,
    this.totp,
    this.webauthn,
  });
}

/// Captcha required response with [captcha_key], [captcha_sitekey], and [captcha_service]
@MappableClass()
class CaptchaResponse extends AuthResponse with CaptchaResponseMappable {
  CaptchaResponse({
    required List<dynamic> captcha_key,
    required String captcha_sitekey,
    required String captcha_service,
  });
}

@sealed
abstract class LoginAuthenticator {}

class CredentialsUserAuth extends LoginAuthenticator {
  final String username;
  final String password;

  CredentialsUserAuth({required this.username, required this.password});
}

class CompletedAuth extends AuthResponse {
  final AuthUser authUser;

  CompletedAuth({required this.authUser});
}

/// Generic authentication error with message [error]
class FailedAuth extends AuthResponse {
  String error;
  FailedAuth({required this.error});
}

/// MFA invalid error with message [error]
class MFAInvalidError extends AuthResponse {
  String error;
  MFAInvalidError({required this.error});
}

class NoAuth extends AuthResponse {}
