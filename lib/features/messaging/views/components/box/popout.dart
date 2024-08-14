import 'package:bonfire/features/messaging/controllers/reply.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ContextPopout extends ConsumerStatefulWidget {
  final Snowflake messageId;

  const ContextPopout({
    super.key,
    required this.messageId,
  });

  @override
  _ContextPopoutState createState() => _ContextPopoutState();
}

class _ContextPopoutState extends ConsumerState<ContextPopout> {
  final GlobalKey _buttonKey = GlobalKey();

  void _showPopupMenu() {
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final replyController = ref.read(replyControllerProvider.notifier);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height,
      ),
      items: _buildMenuItems(context),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      color: Theme.of(context).custom.colorTheme.foreground,
    ).then((String? result) {
      if (result == "reply") {
        replyController.setMessageReply(
          ReplyState(
            messageId: widget.messageId,
            shouldMention: false,
          ),
        );
        print("Replying to message");
      } else if (result == "edit") {
        print("Editing message");
      } else if (result == "addReaction") {
        print("Adding reaction");
      } else if (result == "report") {
        print("Reporting message");
      } else if (result == "delete") {
        print("Deleting message");
      }
    });
    print("_showPopupMenu called");
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    print("Building menu items");
    return <PopupMenuEntry<String>>[
      _buildMenuItem(context, 'reply', Icons.reply, 'Reply'),
      _buildMenuItem(context, 'edit', Icons.edit, 'Edit Message'),
      _buildMenuItem(
          context, 'addReaction', Icons.add_reaction, 'Add Reaction'),
      const PopupMenuDivider(),
      _buildMenuItem(context, 'report', Icons.flag, 'Report Message'),
      _buildMenuItem(context, 'delete', Icons.delete, 'Delete Message',
          isDestructive: true),
    ];
  }

  PopupMenuItem<String> _buildMenuItem(
      BuildContext context, String value, IconData icon, String text,
      {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      height: 36,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDestructive ? Colors.red : Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.publicSans(
              color: isDestructive ? Colors.red : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          print("Child tapped");
          _showPopupMenu();
        },
        child: Container(
          key: _buttonKey,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.background,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.more_horiz,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
