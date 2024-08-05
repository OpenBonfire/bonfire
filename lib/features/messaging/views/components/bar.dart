import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/views/components/typing/typing_view.dart';
import 'package:bonfire/features/messaging/views/messages.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:bonfire/shared/utils/platform.dart';

class MessageBar extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Channel channel;

  const MessageBar({super.key, required this.guildId, required this.channel});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageBarState();
}

class _MessageBarState extends ConsumerState<MessageBar> {
  TextEditingController messageBarController = TextEditingController();
  FocusNode messageBarFocusNode = FocusNode();

  Widget _messageBarIcon(SvgPicture icon, void Function() onPressed,
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
        .read(messagesProvider(widget.channel.id).notifier)
        .sendMessage(widget.channel, messageBarController.text);
    messageBarController.text = "";

    // only required on desktop because onSubmit
    messageBarFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    bool isWatch = isSmartwatch(context);
    return Padding(
      padding: EdgeInsets.only(left: isWatch ? 24 : 0, right: 4),
      child: Center(
        child: Column(
          children: [
            TypingView(channelId: widget.channel.id),
            Container(
              height: 60,
              decoration: BoxDecoration(
                  color: isWatch
                      ? Colors.transparent
                      : Theme.of(context)
                          .custom
                          .colorTheme
                          .messageBarBackground,
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Theme.of(context).custom.colorTheme.foreground,
                      width: 1,
                    ),
                  )),
              child: Row(
                children: [
                  if (!isWatch)
                    _messageBarIcon(
                      SvgPicture.asset(
                        "assets/icons/add.svg",
                        width: 24,
                        height: 24,
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
                            padding: const EdgeInsets.only(left: 8),
                            child: Center(
                              child: TextField(
                                focusNode: messageBarFocusNode,
                                controller: messageBarController,
                                onSubmitted: (_) {
                                  if (UniversalPlatform.isDesktopOrWeb) {
                                    _sendMessage();
                                  }
                                },
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 8, bottom: 6),
                                  hintText: isSmartwatch(context)
                                      ? "#${getChannelName(widget.channel)}"
                                      : "Message #${getChannelName(widget.channel)}",
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .custom
                                          .colorTheme
                                          .messageBarHintText),
                                  border: InputBorder.none,
                                ),
                                style: Theme.of(context)
                                    .custom
                                    .textTheme
                                    .bodyText1,
                              ),
                            )),
                      ),
                    ),
                  ),
                  (UniversalPlatform.isMobile)
                      ? Padding(
                          // no idea why this is needed
                          padding: EdgeInsets.only(
                              top: 2, bottom: 2, right: isWatch ? 12 : 0),
                          child: _messageBarIcon(
                            SvgPicture.asset(
                              "assets/icons/send.svg",
                              width: 24,
                              height: 24,
                            ),
                            _sendMessage,
                            backgroundColor:
                                Theme.of(context).custom.colorTheme.blurple,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
