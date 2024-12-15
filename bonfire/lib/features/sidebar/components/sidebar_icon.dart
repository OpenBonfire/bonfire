import 'package:bonfire/features/guild/repositories/guild_icon.dart';
import 'package:bonfire/features/guild/repositories/guild_mentions.dart';
import 'package:bonfire/features/guild/repositories/guild_unreads.dart';
import 'package:bonfire/features/sidebar/components/sidebar_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

class SidebarIcon extends ConsumerWidget {
  final bool selected;
  final UserGuild guild;
  final bool mini;
  final bool isClickable;

  const SidebarIcon({
    super.key,
    required this.selected,
    required this.guild,
    this.mini = false,
    this.isClickable = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var hasUnreads =
        ref.watch(guildUnreadsProvider(guild.id)).valueOrNull ?? false;
    var mentions = ref.watch(guildMentionsProvider(guild.id)).value ?? 0;

    return SidebarItem(
      selected: selected,
      hasUnreads: hasUnreads,
      mentions: mentions,
      mini: mini,
      onTap: () {
        if (isClickable) {
          GoRouter.of(context).go('/channels/${guild.id}/${Snowflake.zero}');
          guild.manager.get(guild.id).then((Guild guild) async {
            var lastGuildChannels = Hive.box("last-guild-channels");
            var channelId = lastGuildChannels.get(guild.id.value.toString()) ??
                guild.rulesChannelId ??
                (await guild.fetchChannels()).first.id.value;

            GoRouter.of(context).go('/channels/${guild.id}/$channelId');
          });
        }
      },
      child: ClipRRect(
        //borderRadius: BorderRadius.circular(25),
        child: _buildGuildIcon(),
      ),
    );
  }

  Widget _buildGuildIcon() {
    return Consumer(
      builder: (context, ref, _) {
        var icon = ref.watch(guildIconProvider(guild.id)).valueOrNull;
        if (icon != null) {
          return Image.memory(icon);
        } else {
          String iconText = guild.name
              .split(" ")
              .map((word) => word.isNotEmpty ? word[0] : '')
              .join();
          return Container(
            color: Theme.of(context).custom.colorTheme.foreground,
            child: Center(
              child: Text(
                iconText,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .custom
                    .textTheme
                    .titleSmall
                    .copyWith(fontSize: mini ? 3 : 12),
              ),
            ),
          );
        }
      },
    );
  }
}
