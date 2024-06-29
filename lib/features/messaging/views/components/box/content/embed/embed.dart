import 'package:bonfire/features/messaging/views/components/box/content/embed/components/image.dart';
import 'package:bonfire/features/messaging/views/components/box/content/embed/components/video.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmbedWidget extends ConsumerStatefulWidget {
  final Embed embed;
  const EmbedWidget({super.key, required this.embed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmbedWidgetState();
}

class _EmbedWidgetState extends ConsumerState<EmbedWidget> {
  String? generateEmbedKey() {
    return widget.embed.thumbnail?.url.toString() ??
        widget.embed.video?.url.toString();
  }

  @override
  Widget build(BuildContext context) {
    Widget embedWidget = Container(key: PageStorageKey(generateEmbedKey()));
    if (widget.embed.image != null) {
      embedWidget = ImageEmbed(embed: widget.embed);
    }
    if (widget.embed.video != null) {
      embedWidget = VideoEmbed(embed: widget.embed);
    }
    return embedWidget;
  }
}
