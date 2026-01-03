import 'package:bonfire/features/channels/components/indicator.dart';
import 'package:bonfire/shared/components/buttons/no_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelButton extends ConsumerWidget {
  final String name;
  final Widget icon;
  final bool selected;
  final void Function() onPressed;
  final void Function()? onLongPress;
  final void Function()? onSecondaryTap;
  final EdgeInsets padding;
  final Widget? trailing;
  final bool hasUnreads;
  final bool muted;
  const ChannelButton({
    super.key,
    required this.name,
    required this.icon,
    required this.selected,
    required this.onPressed,
    this.onLongPress,
    this.onSecondaryTap,
    this.padding = const .symmetric(horizontal: 8, vertical: 8),
    this.trailing,
    this.hasUnreads = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    Color textColor = selected || hasUnreads
        ? theme.colorScheme.onSurface
        : theme.colorScheme.surfaceContainerHighest;
    if (muted && !selected) {
      textColor = theme.colorScheme.surfaceContainerHigh;
    }

    final backgroundColor = selected
        ? theme.colorScheme.surfaceContainer
        : theme.colorScheme.surface;

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              ChannelIndicator(
                selected: selected,
                hasUnreads: hasUnreads && !muted,
              ),

              SizedBox(width: 4),
              Expanded(
                child: NoSplashButton(
                  onPressed: onPressed,
                  onLongPress: onLongPress,
                  onSecondaryTap: onSecondaryTap,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: backgroundColor,
                  child: Padding(
                    padding: const .symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              textColor,
                              BlendMode.srcIn,
                            ),
                            child: icon,
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            name,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              fontSize: 13.5,
                              fontWeight: hasUnreads ? .bold : .w600,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null)
          Positioned(right: 8, child: Center(child: trailing!))
        else if (hasUnreads)
          Positioned(
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: .circle,
              ),
            ),
          ),
      ],
    );
  }
}
