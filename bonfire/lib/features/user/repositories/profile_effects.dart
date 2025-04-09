import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_effects.g.dart';

@riverpod
Future<List<ProfileEffectConfig>?> profileEffects(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthUser) return null;

  return await auth.client.users.fetchProfileEffects();
}
