import 'package:bonfire/features/guild/repositories/guild_icon.dart';
import 'package:bonfire/features/guild/repositories/guild_mentions.dart';
import 'package:bonfire/features/guild/repositories/guild_unreads.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebridge/firebridge.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';

class SidebarIcon extends ConsumerStatefulWidget {
  final bool selected;
  final UserGuild guild;
  final bool mini;
  final bool isClickable;
  final bool isInFolder;

  const SidebarIcon({
    super.key,
    required this.selected,
    required this.guild,
    this.mini = false,
    this.isClickable = true,
    this.isInFolder = false,
  });

  @override
  ConsumerState<SidebarIcon> createState() => _SidebarIconState();
}

class _SidebarIconState extends ConsumerState<SidebarIcon> {
  double _iconHeight = 40;

  @override
  void initState() {
    super.initState();
    _updateIconHeight();
  }

  @override
  void didUpdateWidget(SidebarIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIconHeight();
  }

  void _updateIconHeight() {
    var hasUnreads =
        ref.read(guildUnreadsProvider(widget.guild.id)).valueOrNull ?? false;
    setState(() {
      if (hasUnreads && !widget.selected) {
        _iconHeight = 8;
      } else {
        _iconHeight = 40;
      }
    });
  }

  Widget iconBuilder(UserGuild guild) {
    var icon = ref.watch(guildIconProvider(guild.id)).valueOrNull;
    if (icon != null) {
      return Image.memory(icon);
    } else {
      String iconText = "";
      List<String> words = guild.name.split(" ");
      for (var word in words) {
        if (word.isEmpty) continue;
        iconText += word[0];
      }

      return Container(
        color: Theme.of(context).custom.colorTheme.foreground,
        child: Center(
            child: Text(iconText,
                overflow: TextOverflow.ellipsis,
                style: CustomTextTheme()
                    .titleSmall
                    .copyWith(fontSize: widget.mini ? 3 : 12))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var hasUnreads =
        ref.watch(guildUnreadsProvider(widget.guild.id)).valueOrNull ?? false;
    var mentions = ref.watch(guildMentionsProvider(widget.guild.id)).value ?? 0;

    _updateIconHeight();

    bool showIndicator = (widget.selected || hasUnreads) && !widget.mini;
    if (widget.isInFolder && !widget.selected) {
      showIndicator = false;
    }

    Widget mentionBubble(int count) {
      return Container(
        width: 23,
        height: 23,
        decoration: BoxDecoration(
          color: Theme.of(context).custom.colorTheme.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                    decoration: BoxDecoration(
                  color: Theme.of(context).custom.colorTheme.red,
                  borderRadius: BorderRadius.circular(20),
                ))),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Center(
                child: Text(
                  count.toString(),
                  style: Theme.of(context).custom.textTheme.bodyText1.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: SizedBox(
            width: widget.mini ? 16 : 47,
            height: widget.mini ? 16 : 47,
            child: widget.isClickable
                ? InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.guild.manager
                          .get(widget.guild.id)
                          .then((Guild guild) async {
                        var lastGuildChannels = Hive.box("last-guild-channels");
                        var channelId =
                            lastGuildChannels.get(guild.id.value.toString()) ??
                                guild.rulesChannelId ??
                                (await guild.fetchChannels()).first.id.value;

                        GoRouter.of(context)
                            .go('/channels/${widget.guild.id}/$channelId');
                      });
                    },
                    splashFactory: NoSplash.splashFactory,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(
                              Radius.circular(widget.selected ? 15 : 100)),
                          child: iconBuilder(widget.guild),
                        ),
                        if (mentions > 0 && !widget.mini)
                          Positioned(
                            right: -3,
                            bottom: -3,
                            child: mentionBubble(mentions),
                          ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.all(
                        Radius.circular(widget.selected ? 15 : 100)),
                    child: iconBuilder(widget.guild),
                  ),
          ),
        ),
        if (showIndicator)
          Positioned(
            left: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOutExpo,
              width: 4,
              height: _iconHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
