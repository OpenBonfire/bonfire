import './components/audio_player.dart';
import './components/downloader.dart';
import './components/image.dart';
import './components/desktop_video.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

class AttachmentWidget extends StatefulWidget {
  final Attachment attachment;
  const AttachmentWidget({super.key, required this.attachment});

  @override
  State<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends State<AttachmentWidget> {
  @override
  Widget build(BuildContext context) {
    String contentType = widget.attachment.contentType?.split("/")[0] ?? "";
    if (contentType == "audio") {
      return AudioAttachment(attachment: widget.attachment);
    }

    if (contentType == "image") {
      return ImageAttachment(attachment: widget.attachment);
    }

    if (contentType == "video") {
      if (UniversalPlatform.isDesktopOrWeb) {
        return DesktopVideoAttachment(
          attachment: widget.attachment,
        );
      } else {
        return DesktopVideoAttachment(attachment: widget.attachment);
      }
    }

    return DownloadAttachment(attachment: widget.attachment);
  }
}
