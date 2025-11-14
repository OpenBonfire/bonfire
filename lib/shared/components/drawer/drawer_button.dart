import 'package:bonfire/shared/components/drawer/mobile_drawer.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BonfireDrawerButton extends ConsumerStatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool roundTop;
  final bool roundBottom;
  const BonfireDrawerButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
    this.roundTop = true,
    this.roundBottom = true,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BonfireDrawerButtonState();
}

class _BonfireDrawerButtonState extends ConsumerState<BonfireDrawerButton> {
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.vertical(
      top: widget.roundTop ? const Radius.circular(12) : Radius.zero,
      bottom: widget.roundBottom ? const Radius.circular(12) : Radius.zero,
    );
    final theme = Theme.of(context);
    return OutlinedButton(
        style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            side: const BorderSide(
              color: Colors.transparent,
              width: 0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            foregroundColor: BonfireThemeExtension.of(context).dirtyWhite,
            backgroundColor: BonfireThemeExtension.of(context).foreground),
        onPressed: () {
          GlobalDrawer.of(context)?.closeDrawer();
          widget.onTap();
        },
        child: Container(
            // decoration: BoxDecoration(
            //   color: theme.colorTheme.foreground,
            //   borderRadius: borderRadius,
            // ),
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 12,
            children: [
              Icon(widget.icon, color: widget.color),
              Text(widget.text,
                  style: theme.textTheme.titleSmall!
                      .copyWith(color: widget.color)),
            ],
          ),
        )));
  }
}
