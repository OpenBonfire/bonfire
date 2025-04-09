import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permissions.g.dart';

/// Provider for calculating permissions for a channel
@Riverpod(keepAlive: true)
class ChannelPermissions extends _$ChannelPermissions {
  AuthUser? user;
  @override
  Future<Permissions?> build(Snowflake channelId) async {
    var auth = ref.watch(authProvider.notifier).getAuth();
    if (auth is! AuthUser) return null;
    user = auth;

    Channel channel = ref.watch(channelControllerProvider(channelId))!;
    if (channel is! GuildChannel) return null;

    Guild guild = ref.watch(guildControllerProvider(channel.guildId))!;
    final selfMember = guild.memberList!
        .firstWhere((element) => element.user?.id == auth.client.user.id);

    Permissions permissions = await channel.computePermissionsFor(selfMember);

    return permissions;
  }
}
