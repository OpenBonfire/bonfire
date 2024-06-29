import 'package:bonfire/features/messaging/views/components/box/content/attachment/bounded_content.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';

class ImageAttachment extends StatelessWidget {
  final Attachment attachment;
  const ImageAttachment({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    double aspectRatio = (attachment.width?.toDouble() ?? 1) /
        (attachment.height?.toDouble() ?? 1);

    return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BoundedContent(
          aspectRatio: aspectRatio,
          child: Image.network(attachment.url.toString(), fit: BoxFit.cover),
        ));
  }
}
