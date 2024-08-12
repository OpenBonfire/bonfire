import 'package:bonfire/features/channels/repositories/has_unreads.dart';
import 'package:bonfire/features/voice/repositories/join.dart';
import 'package:bonfire/features/voice/views/voice_members.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/shared/utils/icons.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

class ChannelButton extends ConsumerStatefulWidget {
  final Snowflake currentGuildId;
  final Snowflake currentChannelId;
  final Channel channel;
  const ChannelButton({
    super.key,
    required this.currentGuildId,
    required this.currentChannelId,
    required this.channel,
  });

  @override
  ConsumerState<ChannelButton> createState() => _ChannelButtonState();
}

class _ChannelButtonState extends ConsumerState<ChannelButton> {
  var lastGuildChannels = Hive.box("last-guild-channels");
  Map<int, Widget> categoryMap = {};

  Widget mentionBubble(int count) {
    return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: Theme.of(context).custom.colorTheme.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          count.toString(),
          style: Theme.of(context).custom.textTheme.bodyText1.copyWith(
                fontSize: 11,
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
        ));
  }

  @override
  Widget build(BuildContext context) {
    bool selected = widget.channel.id == widget.currentChannelId;
    var readState = ref.watch(channelReadStateProvider(widget.channel.id));
    int mentionCount = readState?.mentionCount ?? 0;

    bool hasUnreads =
        ref.watch(hasUnreadsProvider(widget.channel)).when(data: (data) {
      return data;
    }, loading: () {
      return false;
    }, error: (error, stack) {
      print(stack);
      print("Error: $error");
      return false;
    });

    return Column(
      children: [
        Row(
          children: [
            (hasUnreads == true)
                ? Container(
                    width: 3,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                    ),
                  )
                : const SizedBox(width: 3),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2, left: 0, right: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        side: const BorderSide(
                          color: Colors.transparent,
                          width: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        foregroundColor: selected
                            ? Theme.of(context)
                                .custom
                                .colorTheme
                                .selectedChannelText
                            : Theme.of(context)
                                .custom
                                .colorTheme
                                .deselectedChannelText,
                        backgroundColor: selected
                            ? Theme.of(context).custom.colorTheme.foreground
                            : Colors.transparent),
                    onPressed: () {
                      if (widget.channel is GuildVoiceChannel) {
                        ref
                            .read(voiceChannelControllerProvider.notifier)
                            .joinVoiceChannel(
                                widget.currentGuildId, widget.channel.id);
                      } else {
                        // route to channel
                        HapticFeedback.selectionClick();
                        lastGuildChannels.put(widget.currentGuildId.toString(),
                            widget.channel.id.toString());
                        GoRouter.of(context).go(
                            '/channels/${widget.currentGuildId}/${widget.channel.id}');

                        OverlappingPanelsState? overlappingPanelsState =
                            OverlappingPanels.of(context);
                        if (overlappingPanelsState != null) {
                          overlappingPanelsState.moveToState(RevealSide.main);
                        }
                      }
                    },
                    child: SizedBox(
                      height: 35,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Icon(
                                BonfireIcons
                                    .channelIcons[widget.channel.type]!.icon,
                                color: (selected || hasUnreads)
                                    ? Theme.of(context)
                                        .custom
                                        .colorTheme
                                        .selectedChannelText
                                    : Theme.of(context)
                                        .custom
                                        .colorTheme
                                        .deselectedChannelText,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      (widget.channel as GuildChannel).name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context)
                                          .custom
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                              color: (selected || hasUnreads)
                                                  ? Theme.of(context)
                                                      .custom
                                                      .colorTheme
                                                      .selectedChannelText
                                                  : Theme.of(context)
                                                      .custom
                                                      .colorTheme
                                                      .deselectedChannelText),
                                    ),
                                  ),
                                  // const Spacer(),
                                  if (mentionCount > 0)
                                    mentionBubble(mentionCount),
                                ],
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        (widget.channel is GuildVoiceChannel)
            ? ChannelVoiceMembers(
                guildId: widget.currentGuildId,
                channelId: widget.channel.id,
              )
            : const SizedBox(),
      ],
    );
  }
}
