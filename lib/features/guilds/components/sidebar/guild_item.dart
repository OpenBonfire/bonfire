import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:bonfire/features/guilds/components/guild_avatar.dart';
import 'package:bonfire/features/guilds/components/sidebar/item.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GuildSidebarItem extends ConsumerWidget {
  final Snowflake guildId;
  final EdgeInsets? padding;
  const GuildSidebarItem({super.key, required this.guildId, this.padding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guild = ref.watch(guildProvider(guildId));
    final client = ref.watch(clientControllerProvider);
    if (guild == null || client == null) {
      return Center(child: CircularProgressIndicator.adaptive());
    }
    final rawGuildId = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.pathParameters["guildId"];

    return SidebarItem(
      padding: padding,
      selected: rawGuildId == guildId.toString(),
      hasUnreads: ref.watch(guildHasUnreadsProvider(guildId)),
      title: guild.name,
      onPressed: () {
        HapticFeedback.lightImpact();
        context.go("/channels/$guildId");
      },
      child: GuildAvatar(guild: guild, client: client),
    );
  }
}
