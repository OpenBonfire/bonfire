import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/views/messages.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_platform/universal_platform.dart';

class MessageBar extends ConsumerStatefulWidget {
  final Guild guild;
  final Channel channel;

  const MessageBar({super.key, required this.guild, required this.channel});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageBarState();
}

class _MessageBarState extends ConsumerState<MessageBar> {
  TextEditingController messageBarController = TextEditingController();
  FocusNode messageBarFocusNode = FocusNode();

  Widget _messageBarIcon(Icon icon, void Function() onPressed,
      {Color? backgroundColor}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color:
              backgroundColor ?? Theme.of(context).custom.colorTheme.messageBar,
          shape: BoxShape.circle,
        ),
        child: IconButton(icon: icon, onPressed: onPressed),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  _sendMessage() {
    ref
        .read(messagesProvider(widget.guild.id, widget.channel.id).notifier)
        .sendMessage(widget.channel, messageBarController.text);
    messageBarController.text = "";

    // only required on desktop because onSubmit
    messageBarFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
          color: Theme.of(context).custom.colorTheme.messageBarBackground,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Theme.of(context).custom.colorTheme.foreground,
              width: 1,
            ),
          )),
      child: Row(
        children: [
          _messageBarIcon(
            Icon(
              Icons.add,
              color:
                  Theme.of(context).custom.colorTheme.messageBarActivatedIcon,
            ),
            () => print("add"),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).custom.colorTheme.messageBar,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Center(
                      child: TextField(
                        focusNode: messageBarFocusNode,
                        controller: messageBarController,
                        onSubmitted: (_) {
                          if (UniversalPlatform.isDesktopOrWeb) _sendMessage();
                        },
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(left: 8, bottom: 6),
                          hintText:
                              "Message #${getChannelName(widget.channel)}",
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .custom
                                  .colorTheme
                                  .messageBarHintText),
                          border: InputBorder.none,
                        ),
                        style: Theme.of(context).custom.textTheme.bodyText1,
                      ),
                    )),
              ),
            ),
          ),
          (UniversalPlatform.isMobile)
              ? _messageBarIcon(
                  const Icon(
                    Icons.send,
                    color: Colors.white,
                    weight: 10,
                  ),
                  _sendMessage,
                  backgroundColor: Theme.of(context).custom.colorTheme.blurple,
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
