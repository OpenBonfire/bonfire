import 'package:bonfire/features/messaging/views/components/box/content/embed/components/web_video.dart';
import 'package:bonfire/features/messaging/views/components/box/content/shared/desktop_video_player.dart';
import 'package:bonfire/features/messaging/views/components/box/content/shared/mobile_video_player.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

class VideoEmbed extends StatelessWidget {
  final Embed embed;
  const VideoEmbed({super.key, required this.embed});

  @override
  Widget build(BuildContext context) {
    return _buildVideoWidget(context);
  }

  Widget _buildVideoWidget(BuildContext context) {
    if (embed.provider?.name == "YouTube") {
      return WebVideo(embed: embed);
    }

    if (embed.thumbnail?.width == null) {
      return const SizedBox();
    }

    if (embed.provider?.name == "Tenor") {
      return UniversalPlatform.isDesktopOrWeb
          ? DesktopVideoPlayer(
              width: embed.thumbnail!.width!.toDouble(),
              height: embed.thumbnail!.height!.toDouble(),
              url: embed.video!.url!,
              thumbnailUrl: embed.thumbnail!.url,
              placeholder: embed.thumbnail!.url.toString(),
            )
          // : DesktopVideoPlayer(
          //     width: embed.thumbnail!.width!.toDouble(),
          //     height: embed.thumbnail!.height!.toDouble(),
          //     url: embed.video!.url!);
          : MobileVideoPlayer(
              width: embed.thumbnail!.width!.toDouble(),
              height: embed.thumbnail!.height!.toDouble(),
              url: embed.video!.url!,
            );

      //     url: embed.video!.url!);
    }

    return AspectRatio(
      aspectRatio: (embed.image?.width ?? 1) / (embed.image?.height ?? 1),
      child: Image.network(embed.thumbnail!.url.toString(), fit: BoxFit.cover),
    );
  }
}
