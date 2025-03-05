import 'package:bonfire/features/messaging/components/box/content/attachment/bounded_content.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';

class ImageEmbed extends StatelessWidget {
  final Embed embed;
  const ImageEmbed({super.key, required this.embed});

  @override
  Widget build(BuildContext context) {
    double aspectRatio = (embed.thumbnail?.width?.toDouble() ?? 1) /
        (embed.thumbnail?.height?.toDouble() ?? 1);

    return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BoundedContent(
          aspectRatio: aspectRatio,
          child: Image.network(embed.url.toString(), fit: BoxFit.cover),
        ));
  }
}
