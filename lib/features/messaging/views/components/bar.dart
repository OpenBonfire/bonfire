import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/views/components/typing/typing_view.dart';
import 'package:bonfire/features/messaging/views/messages.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:bonfire/shared/utils/platform.dart';

class EnterKeyFormatter extends TextInputFormatter {
  final bool isShiftPressed;

  EnterKeyFormatter({required this.isShiftPressed});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.endsWith('\n') &&
        !isShiftPressed &&
        UniversalPlatform.isDesktop) {
      return oldValue;
    }
    return newValue;
  }
}

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
  late TextEditingController messageBarController;
  late FocusNode messageBarFocusNode;
  bool _isShiftPressed = false;

  @override
  void initState() {
    super.initState();
    messageBarController = TextEditingController();
    messageBarFocusNode = FocusNode();
  }

  @override
  void dispose() {
    messageBarController.dispose();
    messageBarFocusNode.dispose();
    super.dispose();
  }

  Widget _messageBarIcon(SvgPicture icon, void Function() onPressed,
      {Color? backgroundColor, BorderRadius? borderRadius}) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color:
            backgroundColor ?? Theme.of(context).custom.colorTheme.foreground,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Center(child: icon),
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.shiftLeft ||
          event.physicalKey == PhysicalKeyboardKey.shiftRight) {
        setState(() => _isShiftPressed = true);
      } else if (event.physicalKey == PhysicalKeyboardKey.enter &&
          !_isShiftPressed &&
          UniversalPlatform.isDesktop) {
        _sendMessage();
      }
    } else if (event is KeyUpEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.shiftLeft ||
          event.physicalKey == PhysicalKeyboardKey.shiftRight) {
        setState(() => _isShiftPressed = false);
      }
    }
  }

  void _sendMessage() {
    final message = messageBarController.text.trim();
    if (message.isNotEmpty) {
      ref
          .read(messagesProvider(widget.channel.id).notifier)
          .sendMessage(widget.channel, message);
      setState(() {
        messageBarController.clear();
      });
      messageBarFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWatch = isSmartwatch(context);

    return Column(
      children: [
        TypingView(channelId: widget.channel.id),
        Padding(
          padding: widget.padding,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).custom.colorTheme.foreground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
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
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 4 * 24,
                    ),
                    child: TextSelectionTheme(
                      data: TextSelectionThemeData(
                        cursorColor:
                            Theme.of(context).custom.colorTheme.blurple,
                        selectionColor:
                            Theme.of(context).custom.colorTheme.blurple,
                        selectionHandleColor:
                            Theme.of(context).custom.colorTheme.blurple,
                      ),
                      child: KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: _handleKeyEvent,
                        child: TextField(
                          focusNode: messageBarFocusNode,
                          controller: messageBarController,
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          onSubmitted: (_) => _sendMessage(),
                          inputFormatters: [
                            EnterKeyFormatter(isShiftPressed: _isShiftPressed),
                          ],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            hintText: isWatch
                                ? "#${getChannelName(widget.channel)}"
                                : "Message #${getChannelName(widget.channel)}",
                            hintStyle: GoogleFonts.publicSans(
                              color: Theme.of(context)
                                  .custom
                                  .colorTheme
                                  .messageBarHintText,
                              fontWeight: FontWeight.w600,
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          style: Theme.of(context).custom.textTheme.bodyText1,
                          cursorColor: Colors.white,
                        ),
                      ),
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
      ],
    );
  }
}
