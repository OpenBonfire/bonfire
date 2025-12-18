import 'package:bonfire/features/authentication/models/auth.dart';
import 'package:firebridge/firebridge.dart';

class AuthUser extends AuthResponse {
  final FirebridgeGateway client;
  final String token;

  AuthUser({required this.token, required this.client});
}
