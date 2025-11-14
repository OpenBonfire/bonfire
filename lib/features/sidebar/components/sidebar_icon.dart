import 'package:bonfire/features/guild/repositories/guild_mentions.dart';
import 'package:bonfire/features/guild/repositories/guild_unreads.dart';
import 'package:bonfire/features/sidebar/components/sidebar_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

class SidebarIcon extends ConsumerStatefulWidget {
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
  ConsumerState<SidebarIcon> createState() => _SidebarIconState();
}

class _SidebarIconState extends ConsumerState<SidebarIcon> {
  @override
  Widget build(BuildContext context) {
    var hasUnreads =
        ref.watch(guildUnreadsProvider(widget.guild.id)).valueOrNull ?? false;
    var mentions = ref.watch(guildMentionsProvider(widget.guild.id)).value ?? 0;

    return SidebarItem(
      selected: widget.selected,
      hasUnreads: hasUnreads,
      mentions: mentions,
      mini: widget.mini,
      onTap: () {
        if (widget.isClickable) {
          GoRouter.of(context)
              .go('/channels/${widget.guild.id}/${Snowflake.zero}');
          widget.guild.manager.get(widget.guild.id).then((Guild guild) async {
            var lastGuildChannels = Hive.box("last-guild-channels");
            var channelId = lastGuildChannels.get(guild.id.value.toString()) ??
                guild.rulesChannelId ??
                (await guild.fetchChannels()).first.id.value;

            // if mounted
            if (mounted) {
              GoRouter.of(context).go('/channels/${guild.id}/$channelId');
            }
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
        if (widget.guild.icon != null) {
          return CachedNetworkImage(
            imageUrl: widget.guild.icon!.url.toString(),
            cacheKey: widget.guild.iconHash!,
          );
        } else {
          String iconText = widget.guild.name
              .split(" ")
              .map((word) => word.isNotEmpty ? word[0] : '')
              .join();
          return Container(
            color: BonfireThemeExtension.of(context).foreground,
            child: Center(
              child: Text(
                iconText,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontSize: widget.mini ? 3 : 12),
              ),
            ),
          );
        }
      },
    );
  }
}
