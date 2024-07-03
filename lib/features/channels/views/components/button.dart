import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/views/components/voice_members.dart';
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

  @override
  Widget build(BuildContext context) {
    bool selected = widget.channel.id == widget.currentChannelId;
    var readState = ref.watch(channelReadStateProvider);
    // bool hasUnreads = (readState?[widget.channel.id]?.flags == 0);
    // print(readState?[widget.channel.id]?.flags);

    bool hasUnreads = false;
    // readState![widget.channel.id]?.lastPartialMessage?.get().then((value) {
    //   value.timestamp.
    // });

    // (widget.channel as GuildVoiceChannel).

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2, left: 8, right: 10),
          child: SizedBox(
            width: double.infinity,
            height: 35,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  side: BorderSide(
                    color: (widget.channel.id == widget.currentChannelId)
                        ? Theme.of(context)
                            .custom
                            .colorTheme
                            .deselectedChannelText
                        : Colors.transparent,
                    width: 0.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: selected
                      ? Theme.of(context).custom.colorTheme.selectedChannelText
                      : Theme.of(context)
                          .custom
                          .colorTheme
                          .deselectedChannelText,
                  backgroundColor: selected
                      ? Theme.of(context).custom.colorTheme.foreground
                      : Colors.transparent),
              onPressed: () {
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
              },
              child: SizedBox(
                height: 35,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        BonfireIcons.channelIcons[widget.channel.type]!,
                        const SizedBox(width: 8),
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
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        (widget.channel is GuildVoiceChannel)
            ? const ChannelVoiceMembers()
            : const SizedBox(),
      ],
    );
  }
}
