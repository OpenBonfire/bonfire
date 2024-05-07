import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/current_guild.dart';
import 'package:bonfire/features/messaging/controllers/message_bar.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/views/embed.dart';
import 'package:bonfire/shared/models/message.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_viewer/markdown_viewer.dart';

class MessageView extends ConsumerStatefulWidget {
  const MessageView({super.key});

  @override
  ConsumerState<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageView> {
  final ScrollController _scrollController = ScrollController();
  Map<int, Widget> messageWidgets = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 100 &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 10000) {
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    // It will try to load messages really fast, so this prevents us
    // from hitting a rate limit, as well as lagging due to unnecessary
    // state updates.
    if (!ref.read(messagesProvider.notifier).loadingMessages) {
      ref.read(messagesProvider.notifier).fetchMoreMessages();
    }
  }

  Widget _messageBarIcon(Icon icon, void Function() onPressed,
      {Color? backgroundColor}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ??
              Theme.of(context).custom.colorTheme.cardSelected,
          shape: BoxShape.circle,
        ),
        child: IconButton(icon: icon, onPressed: onPressed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var messageOutput = ref.watch(messagesProvider);
    var messages = messageOutput.valueOrNull ?? [];
    var topPadding = MediaQuery.of(context).padding.top;
    var height = MediaQuery.of(context).size.height;

    var currentGuild = ref.watch(currentGuildControllerProvider);
    var currentChannel =
        ref.read(channelControllerProvider.notifier).getChannel();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.foreground,
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, -1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: topPadding + 50,
            decoration: BoxDecoration(
              color: Theme.of(context).custom.colorTheme.foreground,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).custom.colorTheme.brightestGray,
                  width: 1,
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text(
                        (currentGuild != null && currentChannel != null)
                            ? "# ${currentChannel.name}"
                            : "",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).custom.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: height - topPadding - 30 - 110,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                var box = messageWidgets[messages[index].id];
                bool showAuthor = true;

                if (index + 1 < messages.length) {
                  showAuthor = messages[index + 1].member.id ==
                      messages[index].member.id;
                }

                box ??= MessageBox();

                (box as MessageBox);
                box.setMessage(messages[index]);
                box.setShowSenderInfo(!showAuthor);
                messageWidgets[messages[index].id] = box;

                return box;
              },
            ),
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
                color: Theme.of(context).custom.colorTheme.foreground,
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: Theme.of(context).custom.colorTheme.brightestGray,
                    width: 1,
                  ),
                )),
            child: Row(
              children: [
                _messageBarIcon(
                  const Icon(
                    Icons.add,
                    // TODO: This might be bad for light theme.
                    color: Colors.white,
                  ),
                  () => print("add"),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).custom.colorTheme.cardSelected,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: TextField(
                          controller: messageBarController,
                          decoration: InputDecoration(
                            hintText:
                                'Message #${(currentChannel != null) ? currentChannel.name : ""}',
                            hintStyle: const TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          style: Theme.of(context).custom.textTheme.bodyText1,
                        ),
                      ),
                    ),
                  ),
                ),
                _messageBarIcon(
                  const Icon(
                    Icons.send,
                    color: Colors.white,
                    weight: 10,
                  ),
                  () {
                    print("sending message: ");
                    print(messageBarController.text);
                    ref
                        .read(messagesProvider.notifier)
                        .sendMessage(messageBarController.text);
                    messageBarController.text = "";
                  },
                  backgroundColor:
                      Theme.of(context).custom.colorTheme.blurpleColor,
                ),
              ],
            ),
          ),
          Container(
            // bottom padding is just returning 0...
            height: 30,
          )
        ],
      ),
    );
  }
}

class MessageBox extends ConsumerStatefulWidget {
  BonfireMessage? message;
  bool showSenderInfo = true;
  MessageBox({Key? key}) : super(key: key);

  @override
  ConsumerState<MessageBox> createState() => _MessageBoxState();

  void setMessage(BonfireMessage message) {
    this.message = message;
  }

  void setShowSenderInfo(bool showSenderInfo) {
    this.showSenderInfo = showSenderInfo;
  }
}

class _MessageBoxState extends ConsumerState<MessageBox>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String dateTimeFormat(DateTime time) {
    String section1;
    String section2;

    if (time.day == DateTime.now().day) {
      section1 = 'Today';
    } else if (time.day == DateTime.now().day - 1) {
      section1 = 'Yesterday';
    } else {
      section1 = '${time.month}/${time.day}/${time.year}';
    }

    var twelveHour = time.hour > 12 ? time.hour - 12 : time.hour;
    var section3 = time.hour > 12 ? 'PM' : 'AM';

    if (twelveHour == 0) {
      twelveHour = 12;
    }

    section2 = ' at $twelveHour:${time.minute} $section3';

    if (time.minute < 10) {
      section2 = ' at $twelveHour:0${time.minute} $section3';
    }

    return section1 + section2;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var width = MediaQuery.of(context).size.width;
    var embeds = widget.message!.embeds ?? [];

    if (embeds.isNotEmpty) {
      // print("building with embeds");
      // print(embeds[0].type);
    }

    var name =
        widget.message!.member.nickName ?? widget.message!.member.displayName;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        side: const BorderSide(
          color: Color.fromARGB(0, 255, 255, 255),
          width: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      onPressed: () {},
      child: Padding(
        padding: EdgeInsets.only(top: widget.showSenderInfo ? 16 : 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.showSenderInfo == true)
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                        width: 45,
                        height: 45,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: (widget.message!.member.icon != null)
                                ? Image(
                                    image: widget.message!.member.icon!.image)
                                : FutureBuilder(
                                    future: ref
                                        .read(messagesProvider.notifier)
                                        .fetchMemberAvatar(
                                            widget.message!.member),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return Image.memory(snapshot.data!);
                                      } else {
                                        return const SizedBox(
                                          width: 45,
                                          height: 45,
                                        );
                                      }
                                    }))))
                : const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 45,
                      height: 45,
                    ),
                  ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.showSenderInfo
                    ? SizedBox(
                        width: width - 100,
                        child: Wrap(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(left: 6, top: 0),
                                child: Text(
                                  name,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            Padding(
                              // I dislike the top padding, should fix alignment
                              padding: const EdgeInsets.only(left: 6, top: 4),
                              child: Text(
                                dateTimeFormat(
                                    widget.message!.timestamp.toLocal()),
                                textAlign: TextAlign.left,
                                softWrap: true,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  color: Color.fromARGB(189, 255, 255, 255),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 0),
                  child: SizedBox(
                    width: width - 105,
                    child: MarkdownViewer(
                      widget.message!.content,
                      enableTaskList: true,
                      enableSuperscript: false,
                      enableSubscript: false,
                      enableFootnote: false,
                      enableImageSize: false,
                      selectable: false,
                      enableKbd: false,
                      syntaxExtensions: const [],
                      elementBuilders: const [],
                      onTapLink: (href, title) {
                        print("Tapped link: $href");
                      },
                      styleSheet: MarkdownStyle(
                          paragraph:
                              Theme.of(context).custom.textTheme.bodyText1),
                    ),
                  ),
                ),
                // add per embed
                for (var embed in embeds)
                  EmbedWidget(
                    embed: embed,
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
