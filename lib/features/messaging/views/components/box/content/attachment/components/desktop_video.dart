import 'package:bonfire/features/messaging/views/components/box/content/shared/desktop_video_player.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';

class DesktopVideoAttachment extends StatelessWidget {
  final Attachment attachment;
  const DesktopVideoAttachment({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    return DesktopVideoPlayer(
        width: attachment.width!.toDouble(),
        height: attachment.height!.toDouble(),
        url: attachment.url);
  }
}
