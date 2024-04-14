import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyxx/nyxx.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

@riverpod
Future<NyxxGateway> authenticate(AuthenticateRef ref, String token) async {
  print("auth code running! hopefully this only happens when logging in.");
  final client = Nyxx.connectGateway(token, GatewayIntents.allUnprivileged);

  return client;
}
