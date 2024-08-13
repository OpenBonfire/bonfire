import 'package:bonfire/features/messaging/views/components/box/content/attachment/bounded_content.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thumbhash/flutter_thumbhash.dart';
import 'dart:ui';

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

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          BlurredBackgroundPageRoute(
            builder: (context) => FullscreenImageView(
              imageUrl: widget.attachment.url.toString(),
              placeholder: hash,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BoundedContent(
          aspectRatio: aspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FadeInImage(
                placeholder: hash.toImage(),
                image: NetworkImage(widget.attachment.url.toString()),
                fit: BoxFit.cover,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              );
            },
          ),
        ),
      ),
    );
  }
}

class BlurredBackgroundPageRoute<T> extends PageRoute<T> {
  BlurredBackgroundPageRoute({
    required this.builder,
    super.settings,
  }) : super(fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20 * animation.value,
            sigmaY: 20 * animation.value,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: builder(context),
    );
  }
}

class FullscreenImageView extends StatelessWidget {
  final String imageUrl;
  final ThumbHash placeholder;

  const FullscreenImageView({
    super.key,
    required this.imageUrl,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: FadeInImage(
                placeholder: placeholder.toImage(),
                image: NetworkImage(imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
