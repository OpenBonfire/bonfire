import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SidebarIndicator extends ConsumerWidget {
  final bool selected;
  final bool hasUnreads;
  const SidebarIndicator({
    super.key,
    required this.selected,
    required this.hasUnreads,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      width: 5,
      height: selected ? 36 : 12,
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
