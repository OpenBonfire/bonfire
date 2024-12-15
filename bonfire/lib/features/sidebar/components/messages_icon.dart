import 'package:bonfire/features/sidebar/components/sidebar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MessagesIcon extends ConsumerWidget {
  final bool selected;
  const MessagesIcon({super.key, this.selected = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SidebarItem(
      selected: selected,
      onTap: () {
        GoRouter.of(context).go('/channels/@me');
      },
      child: Transform.scale(
        scale: 0.4,
        child: SvgPicture.asset(
          'assets/icons/dms.svg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
