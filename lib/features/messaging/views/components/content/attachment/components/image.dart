import 'dart:math';

import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';

class ImageAttachment extends StatelessWidget {
  final Attachment attachment;
  const ImageAttachment({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: min(attachment.width?.toDouble() ?? double.infinity,
            MediaQuery.of(context).size.width - 90),
        child: AspectRatio(
          aspectRatio: (attachment.width?.toDouble() ?? 1) /
              (attachment.height?.toDouble() ?? 1),
          child: Image.network(attachment.url.toString(), fit: BoxFit.cover),
        ),
      ),
    );
  }
}
