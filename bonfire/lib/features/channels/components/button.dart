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
import 'package:hive_ce/hive.dart';

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

  Widget _buildMentionBubble(int count) {
    return Container(
      width: 23,
      height: 23,
      decoration: BoxDecoration(
        color: BonfireThemeExtension.of(context).background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                color: BonfireThemeExtension.of(context).red,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Center(
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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

  @override
  Widget build(BuildContext context) {
    bool selected = widget.channel.id == widget.currentChannelId;
    var readState = ref.watch(channelReadStateProvider(widget.channel.id));
    int mentionCount = readState?.mentionCount ?? 0;

    final bonfireTheme = BonfireThemeExtension.of(context);

    bool hasUnreads =
        ref.watch(hasUnreadsProvider(widget.channel.id)).when(data: (data) {
      return data;
    }, loading: () {
      return false;
    }, error: (error, stack) {
      debugPrint(stack.toString());
      debugPrint("Error: $error");
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
                  height: 36,
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
                            ? BonfireThemeExtension.of(context).dirtyWhite
                            : BonfireThemeExtension.of(context).gray,
                        backgroundColor: selected
                            ? BonfireThemeExtension.of(context).foreground
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
                                    ? bonfireTheme.dirtyWhite
                                    : BonfireThemeExtension.of(context).gray,
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
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: (selected || hasUnreads)
                                                  ? bonfireTheme.dirtyWhite
                                                  : bonfireTheme.gray),
                                    ),
                                  ),
                                  // const Spacer(),
                                  if (mentionCount > 0)
                                    _buildMentionBubble(mentionCount),
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
