import 'package:bonfire/features/channels/repositories/voice/voice_members.dart';
import 'package:bonfire/features/user/card/repositories/user.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelVoiceMembers extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  const ChannelVoiceMembers({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  @override
  ConsumerState<ChannelVoiceMembers> createState() =>
      _ChannelVoiceMembersState();
}

class _ChannelVoiceMembersState extends ConsumerState<ChannelVoiceMembers> {
  @override
  Widget build(BuildContext context) {
    List<MapEntry<Snowflake, VoiceState>>? voiceMembers = ref
        .watch(voiceMembersProvider(
          widget.guildId,
          channelId: widget.channelId,
        ))
        .valueOrNull;

    // print(voiceMember.value.member);

    // List<User> users = [];
    // if (voiceMembers != null) {
    //   for (var voiceMember in voiceMembers) {
    //     User? user = ref
    //         .watch(getUserFromIdProvider(voiceMember.value.user.id))
    //         .valueOrNull;
    //     if (user != null) users.add(user);
    //   }
    // }

    return (voiceMembers != null)
        ? Row(
            children: [
              for (var voiceMember in voiceMembers)
                Expanded(
                    child: VoiceMemberCard(userId: voiceMember.value.userId)),
            ],
          )
        : const SizedBox();
  }
}

class VoiceMemberCard extends ConsumerStatefulWidget {
  final Snowflake userId;
  const VoiceMemberCard({super.key, required this.userId});

  @override
  ConsumerState<VoiceMemberCard> createState() => _VoiceMemberCardState();
}

class _VoiceMemberCardState extends ConsumerState<VoiceMemberCard> {
  @override
  Widget build(BuildContext context) {
    User? user = ref.watch(getUserFromIdProvider(widget.userId)).valueOrNull;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        side: const BorderSide(
          color: Colors.transparent,
          width: 0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        foregroundColor:
            Theme.of(context).custom.colorTheme.deselectedChannelText,
        backgroundColor: Colors.transparent,
      ),
      onPressed: () {},
      child: SizedBox(
        height: 35,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white)),
                const SizedBox(width: 8),
                Expanded(
                    child: Row(
                  children: [
                    Text(
                      // todo: I need to get the member for nickname
                      user!.globalName ?? user.username,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.left,
                      style: Theme.of(context)
                          .custom
                          .textTheme
                          .bodyText1
                          .copyWith(
                              color: Theme.of(context)
                                  .custom
                                  .colorTheme
                                  .deselectedChannelText),
                    ),
                    const Spacer(),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
