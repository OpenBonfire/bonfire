import 'package:bonfire/shared/components/drawer/drawer_button.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContextDrawer extends ConsumerStatefulWidget {
  final Snowflake messageId;
  const ContextDrawer({
    super.key,
    required this.messageId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContextDrawerState();
}

class _ContextDrawerState extends ConsumerState<ContextDrawer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          BonfireDrawerButton(
            text: 'Reply',
            icon: Icons.reply,
            color: Colors.white,
            roundBottom: false,
            onTap: () {},
          ),
          BonfireDrawerButton(
            text: 'Delete',
            icon: Icons.delete,
            color: Colors.red,
            roundBottom: false,
            roundTop: false,
            onTap: () {},
          ),
          BonfireDrawerButton(
            text: 'Edit',
            icon: Icons.edit,
            color: Theme.of(context).custom.colorTheme.selectedChannelText,
            roundTop: false,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          BonfireDrawerButton(
            text: 'Copy Text',
            icon: Icons.copy_rounded,
            color: Theme.of(context).custom.colorTheme.selectedChannelText,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          BonfireDrawerButton(
            text: 'Copy Message ID',
            icon: Icons.developer_board_rounded,
            color: Theme.of(context).custom.colorTheme.selectedChannelText,
            roundBottom: false,
            onTap: () {},
          ),
          BonfireDrawerButton(
            text: 'Copy Message Link',
            icon: Icons.link_rounded,
            color: Theme.of(context).custom.colorTheme.selectedChannelText,
            roundTop: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
