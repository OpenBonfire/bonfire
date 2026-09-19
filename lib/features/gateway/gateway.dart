import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/members/repositories/channel_members.dart';
import 'package:bonfire/shared/database/database_provider.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gateway.g.dart';

@Riverpod(keepAlive: true)
class GatewayController extends _$GatewayController {
  FirebridgeGateway? _currentClient;

  @override
  void build() {
    final client = ref.watch(clientControllerProvider);

    // If client changed, clean up and resubscribe
    if (_currentClient != client) {
      if (_currentClient != null) {
        // logger.info("Client changed, invalidating caches and resubscribing...");
        // _invalidateAllCaches();
        // _invalidateUserEvents();
        // _invalidateClubEvents();
      }

      _currentClient = null;

      if (client == null) return;

      _currentClient = client;
      _subscribeToClient(client);
    }
  }

  void _subscribeToClient(FirebridgeGateway client) {
    client.onCacheUpdate.listen((entity) {
      _handleCacheUpdate(ref, entity);
    });

    client.on<GuildMemberListUpdateEvent>((event) {
      ref
          .read(channelMembersProvider.notifier)
          .updateMemberList(event.operations, event.guildId, event.groups);
    });
  }
}

void _handleCacheUpdate(Ref ref, Object? entity) {
  final db = ref.read(appDatabaseProvider);
  switch (entity) {
    // case ReadyEvent():

    case UserSettings():
      db.upsertGuildFolders(entity.guildFolders);
    case Guild():
      db.upsertGuild(entity);
      db.upsertGuildChannels(entity.id, entity.channels);

    case Channel():
      db.upsertChannel(entity);
  }
}
