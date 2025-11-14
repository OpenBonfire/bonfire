import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

@sealed
abstract class AuthResponse {}

class AuthNotStarted extends AuthResponse {}

/// Successful authentication response with [token] and [user_settings]
@freezed
class AuthSuccess extends AuthResponse with _$AuthSuccess {
  factory AuthSuccess({
    required String token,
    required Map<String, dynamic> user_settings,
  }) = _AuthSuccess;

  factory AuthSuccess.fromJson(Map<String, dynamic> json) =>
      _$AuthSuccessFromJson(json);
}

/// MFA required response with [user_id], [mfa], [ticket], [sms], [backup], [totp], and [webauthn]
@freezed
class MFARequired extends AuthResponse with _$MFARequired {
  factory MFARequired({
    required String user_id,
    required bool mfa,
    required String ticket,
    bool? sms,
    bool? backup,
    bool? totp,
    dynamic webauthn,
  }) = _MFARequired;

  factory MFARequired.fromJson(Map<String, dynamic> json) =>
      _$MFARequiredFromJson(json);
}

/// Captcha required response with [captcha_key], [captcha_sitekey], and [captcha_service]
@freezed
class CaptchaResponse extends AuthResponse with _$CaptchaResponse {
  factory CaptchaResponse({
    required List<dynamic> captcha_key,
    required String captcha_sitekey,
    required String captcha_service,
  }) = _CaptchaResponse;

  factory CaptchaResponse.fromJson(Map<String, dynamic> json) =>
      _$CaptchaResponseFromJson(json);
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
