import 'package:bonfire/features/messaging/views/components/box/content/shared/mobile_video_player.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';

class MobileVideoAttachment extends StatelessWidget {
  final Attachment attachment;
  const MobileVideoAttachment({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    return MobileVideoPlayer(
      width: attachment.width!.toDouble(),
      height: attachment.height!.toDouble(),
      url: attachment.url,
    );
  }
}
