import 'package:flutter/material.dart';

class MessageLoadingAnimation extends StatefulWidget {
  const MessageLoadingAnimation({super.key});

  @override
  State<MessageLoadingAnimation> createState() =>
      _MessageLoadingAnimationState();
}

class _MessageLoadingAnimationState extends State<MessageLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
    _gradientAnimation =
        Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _pulseAnimation.value,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // avatar placeholder
                _buildGradientContainer(40, 40, BoxShape.circle),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // name placeholder
                      _buildGradientContainer(120, 16, BoxShape.rectangle),
                      const SizedBox(height: 8),
                      // message content placeholder
                      _buildGradientContainer(
                          double.infinity, 16, BoxShape.rectangle),
                      const SizedBox(height: 4),
                      _buildGradientContainer(
                          double.infinity, 16, BoxShape.rectangle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientContainer(double width, double height, BoxShape shape) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(4) : null,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          ],
          stops: [
            0.0,
            _gradientAnimation.value,
            1.0,
          ],
        ),
      ),
    );
  }
}
