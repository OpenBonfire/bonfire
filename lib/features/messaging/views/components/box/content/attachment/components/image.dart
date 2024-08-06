import 'package:bonfire/features/messaging/views/components/box/content/attachment/bounded_content.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thumbhash/flutter_thumbhash.dart';

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

    final hash = ThumbHash.fromBase64(widget.attachment.placeholder!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BoundedContent(
        aspectRatio: aspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FadeInImage(
              placeholder: hash.toImage(),
              image: ResizeImage(
                NetworkImage(widget.attachment.url.toString()),
                width: constraints.maxWidth.round(),
                height: constraints.maxHeight.round(),
              ),
              fit: BoxFit.cover,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            );
          },
        ),
      ),
    );
  }
}
