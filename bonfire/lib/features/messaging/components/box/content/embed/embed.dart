import 'package:bonfire/features/messaging/components/box/content/embed/components/description.dart';
import 'package:bonfire/features/messaging/components/box/content/embed/components/image.dart';
import 'package:bonfire/features/messaging/components/box/content/embed/components/video.dart';
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
  @override
  Widget build(BuildContext context) {
    if (widget.embed.image != null) {
      return ImageEmbed(embed: widget.embed);
    }
    if (widget.embed.video != null) {
      return VideoEmbed(embed: widget.embed);
    }

    if (widget.embed.title != null || widget.embed.description != null) {
      return DescriptionEmbed(embed: widget.embed);
    }

    print("no embed type found");

    return Container();
  }
}
