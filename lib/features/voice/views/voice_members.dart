import 'package:bonfire/features/voice/components/voice_member_card.dart';
import 'package:bonfire/features/voice/repositories/voice_members.dart';
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
        .watch(
          voiceMembersProvider(widget.guildId, channelId: widget.channelId),
        )
        .value;

    return (voiceMembers != null)
        ? Column(
            children: [
              for (var voiceMember in voiceMembers)
                VoiceMemberCard(
                  userId: voiceMember.value.userId,
                  guildId: widget.guildId,
                  channelId: widget.channelId,
                ),
            ],
          )
        : const SizedBox();
  }
}
