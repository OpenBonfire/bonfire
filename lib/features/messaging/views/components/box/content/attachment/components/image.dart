import 'dart:typed_data';

import 'package:bonfire/features/messaging/repositories/image.dart';
import 'package:bonfire/features/messaging/views/components/box/content/attachment/bounded_content.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageAttachment extends ConsumerStatefulWidget {
  final Attachment attachment;
  const ImageAttachment({super.key, required this.attachment});

  @override
  ConsumerState<ImageAttachment> createState() => _ImageAttachmentState();
}

class _ImageAttachmentState extends ConsumerState<ImageAttachment> {
  @override
  Widget build(BuildContext context) {
    double aspectRatio = (widget.attachment.width?.toDouble() ?? 1) /
        (widget.attachment.height?.toDouble() ?? 1);
    Uint8List? image =
        ref.watch(attachedImageProvider(widget.attachment)).valueOrNull;
    return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BoundedContent(
            aspectRatio: aspectRatio,
            child: (image == null)
                // hash is the file name? For some reason?

                ? SizedBox(
                    width: widget.attachment.width!.toDouble(),
                    height: widget.attachment.height!.toDouble(),
                  )
                : Image.memory(image)));
  }
}
