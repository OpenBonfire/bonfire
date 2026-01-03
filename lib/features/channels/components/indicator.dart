import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelIndicator extends ConsumerWidget {
  final bool selected;
  final bool hasUnreads;
  const ChannelIndicator({
    super.key,
    required this.selected,
    required this.hasUnreads,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      width: 4,
      height: selected ? 25 : 8,
      decoration: BoxDecoration(
        color: (hasUnreads || selected)
            ? theme.colorScheme.onSurface
            : Colors.transparent,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
    );
  }
}
