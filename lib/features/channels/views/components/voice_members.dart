import 'package:bonfire/features/channels/repositories/voice/voice_members.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelVoiceMembers extends ConsumerStatefulWidget {
  const ChannelVoiceMembers({super.key});

  @override
  ConsumerState<ChannelVoiceMembers> createState() =>
      _ChannelVoiceMembersState();
}

class _ChannelVoiceMembersState extends ConsumerState<ChannelVoiceMembers> {
  @override
  Widget build(BuildContext context) {
    // var voiceMembers = ref.watch(voiceMembersProvider);
    return const SizedBox();
  }
}
