import 'package:firebridge/firebridge.dart';

/// Compute the permissions for [member] in a given [channel].
///
/// {@template compute_permissions_detail}
/// This method returns the permissions for [member] according to the
/// permissions granted to them by their roles at a guild level as well as
/// the permission overwrites for [channel].
///
/// Adapted from https://discord.com/developers/docs/topics/permissions#permission-overwrites
/// {@endtemplate}
Future<Permissions> computePermissions(GuildChannel channel, Member member,
    {Guild? guild, List<Role>? roles}) async {
  final guildInstance = guild ?? await channel.guild.get();

  Future<Permissions> computeBasePermissions() async {
    if (guildInstance.ownerId == member.id) {
      return Permissions.allPermissions;
    }

    final everyoneRole =
        (roles?.firstWhere((role) => role.id == guildInstance.id)) ??
            await guildInstance.roles[guildInstance.id].get();
    Flags<Permissions> permissions = everyoneRole.permissions;

    for (final role in member.roles) {
      final rolePermissions = (await role.get()).permissions;

      permissions |= rolePermissions;
    }

    permissions = Permissions(permissions.value);
    permissions as Permissions;

    if (permissions.isAdministrator) {
      return Permissions.allPermissions;
    }

    return permissions;
  }

  Future<Permissions> computeOverwrites(Permissions basePermissions) async {
    if (basePermissions.isAdministrator) {
      return Permissions.allPermissions;
    }

    Flags<Permissions> permissions = basePermissions;

    final everyoneOverwrite = channel.permissionOverwrites
        .where((overwrite) => overwrite.id == guildInstance.id)
        .singleOrNull;
    if (everyoneOverwrite != null) {
      permissions &= ~everyoneOverwrite.deny;
      permissions |= everyoneOverwrite.allow;
    }

    Flags<Permissions> allow = Permissions(0);
    Flags<Permissions> deny = Permissions(0);

    for (final roleId in member.roleIds) {
      final roleOverwrite = channel.permissionOverwrites
          .where((overwrite) => overwrite.id == roleId)
          .singleOrNull;
      if (roleOverwrite != null) {
        allow |= roleOverwrite.allow;
        deny |= roleOverwrite.deny;
      }
    }

    permissions &= ~deny;
    permissions |= allow;

    final memberOverwrite = channel.permissionOverwrites
        .where((overwrite) => overwrite.id == member.id)
        .singleOrNull;
    if (memberOverwrite != null) {
      permissions &= ~memberOverwrite.deny;
      permissions |= memberOverwrite.allow;
    }

    return Permissions(permissions.value);
  }

  return computeOverwrites(await computeBasePermissions());
}
