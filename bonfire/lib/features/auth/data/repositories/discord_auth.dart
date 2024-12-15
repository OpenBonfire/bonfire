import 'package:bonfire/features/auth/models/auth.dart';
import 'package:firebridge/firebridge.dart';

class AuthUser extends AuthResponse {
  final NyxxGateway client;
  final String token;

  AuthUser({
    required this.token,
    required this.client,
  });
}
