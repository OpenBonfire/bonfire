import 'package:bonfire/features/guilds/components/sidebar/indicator.dart';
import 'package:bonfire/shared/components/buttons/no_splash.dart';
import 'package:flutter/material.dart';

class SidebarItem extends StatefulWidget {
  final bool selected;
  final bool hasUnreads;
  final String title;
  final VoidCallback? onPressed;
  final Widget? child;
  const SidebarItem({
    super.key,
    required this.selected,
    required this.title,
    this.onPressed,
    this.hasUnreads = false,
    this.child,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SidebarIndicator(
          selected: widget.selected,
          hasUnreads: widget.hasUnreads,
        ),
        SizedBox(width: 4),
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth;
              final selectedRadius = size * 0.22;
              final unselectedRadius = size * 0.5;

              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 150),
                tween: Tween<double>(
                  end: widget.selected ? selectedRadius : unselectedRadius,
                ),
                curve: Curves.linear,
                builder: (context, radius, child) {
                  return AspectRatio(
                    aspectRatio: 1,
                    child: NoSplashButton(
                      borderRadius: BorderRadius.circular(radius),
                      onPressed: widget.onPressed,
                      child: SizedBox.expand(child: widget.child),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
