import 'package:bonfire/features/authenticator/data/repositories/auth.dart';
import 'package:bonfire/features/authenticator/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/guild/controllers/role.dart';
import 'package:bonfire/features/guild/controllers/roles.dart';
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
    List<Snowflake> roleIds =
        ref.watch(rolesControllerProvider(channel.guildId))!;
    List<Role> roles = [];
    for (Snowflake roleId in roleIds) {
      Role role = ref.watch(roleControllerProvider(roleId))!;
      roles.add(role);
    }

    Member? maybeSelf;
    Member? selfMember;
    guild.memberList?.forEach((element) {
      if (element.user?.id == auth.client.user.id) {
        maybeSelf = element;
      }
    });

    if (maybeSelf != null) {
      selfMember = maybeSelf;
    } else {
      // shouldn't ever be called
      selfMember =
          await auth.client.guilds[guild.id].members.get(auth.client.user.id);
    }

    Permissions permissions =
        await channel.computePermissionsForMemberWithGuildAndRoles(
      selfMember!,
      guild,
      roles,
    );

    return permissions;
  }
}
