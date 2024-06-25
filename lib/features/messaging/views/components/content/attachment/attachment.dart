import 'package:bonfire/features/messaging/views/components/content/attachment/components/audio_player.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';

class AttachmentWidget extends StatefulWidget {
  final Attachment attachment;
  const AttachmentWidget({super.key, required this.attachment});

  @override
  State<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends State<AttachmentWidget> {
  @override
  Widget build(BuildContext context) {
    // print("attachment!!!");
    // print(widget.attachment.contentType);
    String contentType = widget.attachment.contentType?.split("/")[0] ?? "";
    if (contentType == "audio") {
      return AudioAttachment(attachment: widget.attachment);
    }

    return Container();
  }
}