import 'package:bonfire/features/messaging/components/box/content/shared/desktop_video_player.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';

class DesktopVideoAttachment extends StatefulWidget {
  final Attachment attachment;
  const DesktopVideoAttachment({super.key, required this.attachment});

  @override
  State<DesktopVideoAttachment> createState() => _DesktopVideoAttachmentState();
}

class _DesktopVideoAttachmentState extends State<DesktopVideoAttachment> {
  @override
  Widget build(BuildContext context) {
    return DesktopVideoPlayer(
      width: widget.attachment.width!.toDouble(),
      height: widget.attachment.height!.toDouble(),
      url: widget.attachment.url,
      thumbnailUrl: widget.attachment.proxiedUrl,
      placeholder: widget.attachment.placeholder,
    );
  }
}
