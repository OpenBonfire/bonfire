import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/messaging/controllers/reply.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/components/box/reply/reply_to.dart';
import 'package:bonfire/features/messaging/components/typing/typing_view.dart';
import 'package:bonfire/features/messaging/repositories/permissions.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/shared/utils/channel_name.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:file_icon/file_icon.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:path/path.dart' as path_lib;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:universal_platform/universal_platform.dart';

class EnterKeyFormatter extends TextInputFormatter {
  final bool isShiftPressed;
  final bool isDesktop;

  EnterKeyFormatter({
    required this.isShiftPressed,
    required this.isDesktop,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.endsWith('\n') && !isShiftPressed && isDesktop) {
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
  final List<AttachmentBuilder> _attachments = [];
  late HorizontalDragGestureRecognizer _attachmentDragRecognizer;

  @override
  void initState() {
    super.initState();
    messageBarController = TextEditingController();
    messageBarFocusNode = FocusNode();
    _attachmentDragRecognizer = HorizontalDragGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  @override
  void dispose() {
    messageBarController.dispose();
    messageBarFocusNode.dispose();
    _attachmentDragRecognizer.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    final overlappingPanelsState = OverlappingPanels.of(context);
    overlappingPanelsState?.setIgnoreGestures(true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {}

  void _handleDragEnd(DragEndDetails details) {
    final overlappingPanelsState = OverlappingPanels.of(context);
    overlappingPanelsState?.setIgnoreGestures(false);
  }

  Widget _messageBarIcon(SvgPicture icon, void Function() onPressed,
      {Color? backgroundColor,
      BorderRadius? borderRadius,
      bool enabled = true}) {
    Color color =
        backgroundColor ?? BonfireThemeExtension.of(context).foreground;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: enabled
            ? InkWell(
                onTap: onPressed,
                borderRadius: borderRadius,
                child: Center(child: icon),
              )
            : Center(
                child: Opacity(opacity: 0.5, child: icon),
              ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event, bool isDesktop) {
    if (event is KeyDownEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.shiftLeft ||
          event.physicalKey == PhysicalKeyboardKey.shiftRight) {
        setState(() => _isShiftPressed = true);
      } else if (event.physicalKey == PhysicalKeyboardKey.enter &&
          !_isShiftPressed &&
          isDesktop) {
        _sendMessage();
      }
    } else if (event is KeyUpEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.shiftLeft ||
          event.physicalKey == PhysicalKeyboardKey.shiftRight) {
        setState(() => _isShiftPressed = false);
      }
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      List<AttachmentBuilder> attachments = [];
      for (final file in result.files) {
        final data = await file.xFile.readAsBytes();
        attachments.add(AttachmentBuilder(data: data, fileName: file.name));
      }
      setState(() {
        _attachments.addAll(attachments);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _sendMessage() {
    final message = messageBarController.text.trim();
    if (message.isNotEmpty || _attachments.isNotEmpty) {
      ref.read(messagesProvider(widget.channel.id).notifier).sendMessage(
            widget.channel,
            message,
            attachments: _attachments,
          );
      ref.read(replyControllerProvider.notifier).setMessageReply(null);
      setState(() {
        messageBarController.clear();
        _attachments.clear();
      });
      messageBarFocusNode.requestFocus();
    }
  }

  Widget _buildAttachmentList() {
    return SizedBox(
      height: 100,
      child: RawGestureDetector(
        gestures: {
          HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
              HorizontalDragGestureRecognizer>(
            () => _attachmentDragRecognizer,
            (_) {},
          ),
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              final attachment = _attachments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AttachmentPreview(
                  attachment: attachment,
                  onDeleted: () => _removeAttachment(index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isWatch = isSmartwatch(context);
    ReplyState? replyState = ref.watch(replyControllerProvider);
    Permissions? channelPermissions =
        ref.watch(channelPermissionsProvider(widget.channel.id)).valueOrNull;
    Channel? channel = ref.watch(channelControllerProvider(widget.channel.id));
    if (channel == null) return const SizedBox.shrink();

    String hintText = "You cannot send messages here";
    if ((channelPermissions?.canSendMessages == true) ||
        channel is! GuildChannel) {
      hintText = isWatch
          ? "#${getChannelName(widget.channel)}"
          : "Message #${getChannelName(widget.channel)}";
    }
    return Column(
      children: [
        TypingView(channelId: widget.channel.id),
        if (_attachments.isNotEmpty) _buildAttachmentList(),
        Padding(
          padding: widget.padding,
          child: Column(
            children: [
              if (replyState != null)
                ReplyTo(
                  messageId: replyState.messageId,
                  shouldMention: replyState.shouldMention,
                ),
              Container(
                decoration: BoxDecoration(
                    color: BonfireThemeExtension.of(context).foreground,
                    borderRadius: (replyState == null)
                        ? BorderRadius.circular(8)
                        : const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          )),
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
                        _pickFiles,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        enabled: channel is! GuildChannel ||
                            (channelPermissions?.canSendMessages == true &&
                                channelPermissions?.canAttachFiles == true),
                      ),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 4 * 24,
                        ),
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            cursorColor:
                                BonfireThemeExtension.of(context).primary,
                            selectionColor:
                                BonfireThemeExtension.of(context).primary,
                            selectionHandleColor:
                                BonfireThemeExtension.of(context).primary,
                          ),
                          child: KeyboardListener(
                            focusNode: FocusNode(),
                            onKeyEvent: (event) => _handleKeyEvent(
                                event, shouldUseDesktopLayout(context)),
                            child: TextField(
                              focusNode: messageBarFocusNode,
                              controller: messageBarController,
                              maxLines: null,
                              minLines: 1,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              onSubmitted: (_) => _sendMessage(),
                              inputFormatters: [
                                EnterKeyFormatter(
                                  isShiftPressed: _isShiftPressed,
                                  isDesktop: shouldUseDesktopLayout(context),
                                ),
                              ],
                              readOnly:
                                  channelPermissions?.canSendMessages == false,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                hintText: hintText,
                                hintStyle: GoogleFonts.publicSans(
                                  color: BonfireThemeExtension.of(context).gray,
                                  fontWeight: FontWeight.w600,
                                ),
                                border: InputBorder.none,
                                isCollapsed: false,
                              ),
                              style: GoogleFonts.publicSans(
                                  color: const Color(0xFFBDBDBD),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.5),
                              cursorColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if ((UniversalPlatform.isMobile ||
                            UniversalPlatform.isWeb) &
                        (channelPermissions?.canSendMessages != false))
                      _messageBarIcon(
                        SvgPicture.asset(
                          "assets/icons/send.svg",
                          width: 24,
                          height: 24,
                        ),
                        _sendMessage,
                        backgroundColor:
                            BonfireThemeExtension.of(context).primary,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AttachmentPreview extends StatelessWidget {
  final AttachmentBuilder attachment;
  final void Function()? onDeleted;

  const AttachmentPreview({
    super.key,
    required this.attachment,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final extension = path_lib.extension(attachment.fileName);
    final isImage = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension.toLowerCase());

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: BonfireThemeExtension.of(context).foreground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    Uint8List.fromList(attachment.data),
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: FileIcon(
                    attachment.fileName,
                    size: 48,
                  ),
                ),
        ),
        if (onDeleted != null)
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: onDeleted,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
