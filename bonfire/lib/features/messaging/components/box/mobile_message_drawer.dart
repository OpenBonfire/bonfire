import 'package:flutter/material.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/features/messaging/controllers/reply.dart';
import 'package:google_fonts/google_fonts.dart';

class MobileMessageDrawer extends ConsumerWidget {
  final Snowflake messageId;

  const MobileMessageDrawer({
    super.key,
    required this.messageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(context),
            ..._buildOptions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color:
              Theme.of(context).custom.colorTheme.foreground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(BuildContext context, WidgetRef ref) {
    final options = [
      _buildOption(
        context,
        icon: Icons.reply,
        text: 'Reply',
        onTap: () => _handleReply(ref),
      ),
      _buildOption(
        context,
        icon: Icons.edit,
        text: 'Edit Message',
        onTap: () => _handleEdit(context),
      ),
      _buildOption(
        context,
        icon: Icons.add_reaction,
        text: 'Add Reaction',
        onTap: () => _handleAddReaction(context),
      ),
      const Divider(height: 1),
      _buildOption(
        context,
        icon: Icons.flag,
        text: 'Report Message',
        onTap: () => _handleReport(context),
      ),
      _buildOption(
        context,
        icon: Icons.delete,
        text: 'Delete Message',
        textColor: Colors.red,
        iconColor: Colors.red,
        onTap: () => _handleDelete(context),
      ),
    ];

    return options;
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor ?? Colors.white,
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: GoogleFonts.publicSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReply(WidgetRef ref) {
    final replyController = ref.read(replyControllerProvider.notifier);
    replyController.setMessageReply(
      ReplyState(
        messageId: messageId,
        shouldMention: false,
      ),
    );
    Navigator.of(ref.context).pop();
    print("Replying to message");
  }

  void _handleEdit(BuildContext context) {
    Navigator.of(context).pop();
    print("Editing message");
  }

  void _handleAddReaction(BuildContext context) {
    Navigator.of(context).pop();
    print("Adding reaction");
  }

  void _handleReport(BuildContext context) {
    Navigator.of(context).pop();
    print("Reporting message");
  }

  void _handleDelete(BuildContext context) {
    Navigator.of(context).pop();
    print("Deleting message");
  }
}
