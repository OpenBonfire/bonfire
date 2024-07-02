import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DirectMessageMember extends ConsumerStatefulWidget {
  final PrivateChannel privateChannel;
  const DirectMessageMember({super.key, required this.privateChannel});

  @override
  ConsumerState<DirectMessageMember> createState() =>
      _DirectMessageMemberState();
}

class _DirectMessageMemberState extends ConsumerState<DirectMessageMember> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: double.infinity,
        height: 35,
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              side: BorderSide(
                color: Theme.of(context).custom.colorTheme.foreground,
                // color: (widget.channel.id == widget.currentChannelId)
                //     ? Theme.of(context).custom.colorTheme.deselectedChannelText
                //     : Colors.transparent,

                width: 0.1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor:
                  Theme.of(context).custom.colorTheme.deselectedChannelText,
              backgroundColor: Colors.transparent,
            ),
            onPressed: () {},
            child: Text(
              widget.privateChannel.recipients
                  .map((e) => e.username)
                  .join(', '),
            )),
      ),
    );
  }
}
