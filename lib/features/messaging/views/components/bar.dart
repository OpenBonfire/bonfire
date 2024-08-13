import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/views/components/typing/typing_view.dart';
import 'package:bonfire/features/messaging/views/messages.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:bonfire/shared/utils/platform.dart';

class MessageBar extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Channel channel;
  final EdgeInsetsGeometry padding;

  const MessageBar({
    super.key,
    required this.guildId,
    required this.channel,
    this.padding = const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 4),
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageBarState();
}

class _MessageBarState extends ConsumerState<MessageBar> {
  TextEditingController messageBarController = TextEditingController();
  FocusNode messageBarFocusNode = FocusNode();

  Widget _messageBarIcon(SvgPicture icon, void Function() onPressed,
      {Color? backgroundColor, BorderRadius? borderRadius}) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ??
                Theme.of(context).custom.colorTheme.foreground,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Center(child: icon),
            ),
          ),
        ),
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

    return Column(
      children: [
        TypingView(channelId: widget.channel.id),
        Padding(
          padding: widget.padding,
          child: IntrinsicHeight(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).custom.colorTheme.foreground,
                borderRadius: BorderRadius.circular(8),
              ),
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
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  Expanded(
                    child: TextSelectionTheme(
                      data: TextSelectionThemeData(
                        cursorColor:
                            Theme.of(context).custom.colorTheme.blurple,
                        selectionColor:
                            Theme.of(context).custom.colorTheme.blurple,
                        selectionHandleColor:
                            Theme.of(context).custom.colorTheme.blurple,
                      ),
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
                              const EdgeInsets.only(left: 4, right: 16),
                          hintText: isSmartwatch(context)
                              ? "#${getChannelName(widget.channel)}"
                              : "Message #${getChannelName(widget.channel)}",
                          hintStyle: GoogleFonts.publicSans(
                              color: Theme.of(context)
                                  .custom
                                  .colorTheme
                                  .messageBarHintText,
                              fontWeight: FontWeight.w600),
                          border: InputBorder.none,
                        ),
                        style: Theme.of(context).custom.textTheme.bodyText1,
                        cursorColor: Colors.white,
                      ),
                    ),
                  ),
                  if (UniversalPlatform.isMobile || UniversalPlatform.isWeb)
                    _messageBarIcon(
                      SvgPicture.asset(
                        "assets/icons/send.svg",
                        width: 24,
                        height: 24,
                      ),
                      _sendMessage,
                      backgroundColor:
                          Theme.of(context).custom.colorTheme.blurple,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
