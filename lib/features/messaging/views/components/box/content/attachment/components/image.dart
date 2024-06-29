import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';

class ImageAttachment extends StatelessWidget {
  final Attachment attachment;
  const ImageAttachment({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double maxHeight = 400;

        double aspectRatio = (attachment.width?.toDouble() ?? 1) /
            (attachment.height?.toDouble() ?? 1);

        double height = maxHeight;
        double width = height * aspectRatio;

        if (width > maxWidth) {
          width = maxWidth;
          height = width / aspectRatio;
        }

        return SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Image.network(
                attachment.url.toString(),
                fit: BoxFit
                    .cover, // Use BoxFit.cover for best fit within constraints
              ),
            ),
          ),
        );
      },
    );
  }
}
