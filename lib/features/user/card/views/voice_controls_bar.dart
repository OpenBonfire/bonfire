import 'package:bonfire/features/voice/repositories/join.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceControlBar extends ConsumerStatefulWidget {
  const VoiceControlBar({super.key});

  @override
  ConsumerState<VoiceControlBar> createState() => _VoiceControlBarState();
}

class _VoiceControlBarState extends ConsumerState<VoiceControlBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.mic_rounded, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.headset_rounded, color: Colors.white),
              onPressed: () {},
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.call_end_rounded, color: Colors.white),
              onPressed: () {
                // ref
                //     .watch(voiceChannelControllerProvider.notifier)
                //     .leaveVoiceChannel();
              },
            ),
          ],
        ),
      ],
    );
  }
}
