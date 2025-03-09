import 'package:bonfire/features/messaging/components/box/content/attachment/bounded_content.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thumbhash/flutter_thumbhash.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';

class ImageAttachment extends ConsumerStatefulWidget {
  final Attachment attachment;
  const ImageAttachment({super.key, required this.attachment});

  @override
  ConsumerState<ImageAttachment> createState() => _ImageAttachmentState();
}

class _ImageAttachmentState extends ConsumerState<ImageAttachment> {
  @override
  void initState() {
    testLoadImage();
    super.initState();
  }

  void testLoadImage() async {
    print("LOADING IMAGE");
    var resp = (await http.get(widget.attachment.url)).statusCode;
    print("Status code: $resp");
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = (widget.attachment.width?.toDouble() ?? 1) /
        (widget.attachment.height?.toDouble() ?? 1);
    ThumbHash? hash;

    if (widget.attachment.placeholder != null) {
      hash = ThumbHash.fromBase64(widget.attachment.placeholder!);
    }
    String urlString = widget.attachment.url.toString();

    // For the web proxy, but this doesn't work... Maybe it doesn't like this specific proxy?
    // Uri url = Uri.parse(widget.attachment.url.toString());

    // if (url.host == "cdn.discordapp.com") {
    //   urlString = Uri.https("cors-proxy.mylo-fawcett.workers.dev", "/", {
    //     'url': urlString,
    //   }).toString();
    // }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          BlurredBackgroundPageRoute(
            builder: (context) => FullscreenImageView(
              imageUrl: urlString,
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
              return (hash != null)
                  ? FadeInImage(
                      placeholder: hash.toImage(),
                      image: NetworkImage(
                        urlString,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      ),
                      fit: BoxFit.contain,
                    )
                  : Image(
                      image: NetworkImage(
                        urlString,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      ),
                      fit: BoxFit.contain,
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

class FullscreenImageView extends StatefulWidget {
  final String imageUrl;
  final ThumbHash? placeholder;

  const FullscreenImageView({
    super.key,
    required this.imageUrl,
    this.placeholder,
  });

  @override
  State<FullscreenImageView> createState() => _FullscreenImageViewState();
}

class _FullscreenImageViewState extends State<FullscreenImageView> {
  final TransformationController _controller = TransformationController();
  late TapDownDetails _doubleTapDetails;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      // Zoom to 2x on double tap
      _controller.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0)
        ..translate(position.dx, position.dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 0.5,
          maxScale: 5,
          child: GestureDetector(
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: Center(
                child: (widget.placeholder != null)
                    ? FadeInImage(
                        placeholder: widget.placeholder!.toImage(),
                        image: NetworkImage(widget.imageUrl),
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        widget.imageUrl,
                        fit: BoxFit.contain,
                      )),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
