import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/views/components/voice_members.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/shared/utils/icons.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelButton extends ConsumerStatefulWidget {
  final GuildChannel channel;
  const ChannelButton({super.key, required this.channel});

  @override
  ConsumerState<ChannelButton> createState() => _ChannelButtonState();
}

class _ChannelButtonState extends ConsumerState<ChannelButton> {
  Map<int, Widget> categoryMap = {};

  @override
  Widget build(BuildContext context) {
    var channelController = ref.watch(channelControllerProvider);
    bool selected = widget.channel == channelController;

    //(widget.channel as GuildVoiceChannel).

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
                    color: (widget.channel == channelController)
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
                ref
                    .read(channelControllerProvider.notifier)
                    .setChannel(widget.channel);

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
                          widget.channel.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.left,
                          style: Theme.of(context)
                              .custom
                              .textTheme
                              .bodyText1
                              .copyWith(
                                  color: selected
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
