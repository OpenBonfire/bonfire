import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'presence.g.dart';

@Riverpod(keepAlive: true)
class PresenceController extends _$PresenceController {
  AuthUser? user;

  @override
  PresenceUpdateEvent? build(Snowflake userId) {
    return null;
  }

  void setPresence(PresenceUpdateEvent presence) {
    state = presence;
  }
}
