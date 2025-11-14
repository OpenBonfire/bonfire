import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SidebarItem extends ConsumerStatefulWidget {
  final bool selected;
  final Widget child;
  final VoidCallback onTap;
  final bool hasUnreads;
  final int mentions;
  final bool mini;

  const SidebarItem({
    super.key,
    required this.selected,
    required this.child,
    required this.onTap,
    this.hasUnreads = false,
    this.mentions = 0,
    this.mini = false,
  });

  @override
  ConsumerState<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends ConsumerState<SidebarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _barAnimation;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _barAnimation = Tween<double>(begin: 8, end: 40).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutExpo,
    ));
    _radiusAnimation =
        Tween<double>(begin: 25, end: 15).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutExpo,
    ));
    if (widget.selected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SidebarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: widget.mini ? 16 : 49,
                  height: widget.mini ? 16 : 49,
                  decoration: BoxDecoration(
                    color: BonfireThemeExtension.of(context).foreground,
                    borderRadius: BorderRadius.circular(
                        widget.mini ? 25 : _radiusAnimation.value),
                  ),
                  child: InkWell(
                    onTap: widget.mini
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            widget.onTap();
                          },
                    splashFactory: NoSplash.splashFactory,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          widget.mini ? 25 : _radiusAnimation.value),
                      child: widget.child,
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.mentions > 0 && !widget.mini)
            Positioned(
              right: 10,
              bottom: -3,
              child: Container(
                decoration: BoxDecoration(
                  color: BonfireThemeExtension.of(context).background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _buildMentionBubble(widget.mentions),
                ),
              ),
            ),
          if ((widget.selected || widget.hasUnreads) && !widget.mini)
            Positioned(
              left: 0,
              child: AnimatedBuilder(
                animation: _barAnimation,
                builder: (context, child) {
                  return Container(
                    width: 5,
                    height: widget.selected ? _barAnimation.value : 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMentionBubble(int count) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: BonfireThemeExtension.of(context).background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: BonfireThemeExtension.of(context).red,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Center(
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
