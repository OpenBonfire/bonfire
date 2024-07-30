import 'dart:typed_data';
import 'package:bonfire/features/messaging/repositories/image.dart';
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
  bool _isImageLoaded = false;

  @override
  Widget build(BuildContext context) {
    double aspectRatio = (widget.attachment.width?.toDouble() ?? 1) /
        (widget.attachment.height?.toDouble() ?? 1);
    Uint8List? image =
        ref.watch(attachedImageProvider(widget.attachment)).valueOrNull;
    final hash = ThumbHash.fromBase64(widget.attachment.placeholder!);

    if (image != null && !_isImageLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isImageLoaded = true;
        });
      });
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BoundedContent(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              width: widget.attachment.width?.toDouble(),
              height: widget.attachment.height?.toDouble(),
              image: hash.toImage(),
              fit: BoxFit.fill,
            ),
            if (image != null)
              AnimatedOpacity(
                opacity: _isImageLoaded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: Image.memory(
                  image,
                  width: widget.attachment.width?.toDouble(),
                  height: widget.attachment.height?.toDouble(),
                  fit: BoxFit.fill,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
