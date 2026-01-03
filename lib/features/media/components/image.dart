import 'package:bonfire/shared/components/shimmer.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class DiscordNetworkImage extends StatelessWidget {
  final String src;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  const DiscordNetworkImage(this.src, {super.key, this.fit, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: ExtendedImage.network(
        src,
        fit: fit,
        borderRadius: borderRadius,
        loadStateChanged: loadStateChange,
      ),
    );
  }

  Widget? loadStateChange(ExtendedImageState state) {
    switch (state.extendedImageLoadState) {
      case LoadState.loading:
        return const ShimmerContainer();
      case LoadState.completed:
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(opacity: value, child: child);
          },
          child: state.completedWidget,
        );
      case LoadState.failed:
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
    }
  }
}
