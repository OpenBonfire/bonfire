import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/current_guild.dart';
import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/messaging/controllers/message_bar.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/views/components/avatar.dart';
import 'package:bonfire/features/messaging/views/embed.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/screen_height.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart'
    as keyboard_size;
import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:flutter_prism/flutter_prism.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

class MessageView extends ConsumerStatefulWidget {
  const MessageView({super.key});

  @override
  ConsumerState<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageView> {
  final ScrollController _scrollController = ScrollController();

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
    ref.read(messagesProvider.notifier).fetchMoreMessages();
  }

  String getChannelName(Channel channel) {
    if (channel.type == ChannelType.guildText) {
      return (channel as GuildTextChannel).name;
    } else {
      return "Name not implemented.";
    }
  }

  @override
  Widget build(BuildContext context) {
    var messageOutput = ref.watch(messagesProvider);
    var messages = messageOutput.valueOrNull ?? [];
    var topPadding = MediaQuery.of(context).padding.top;

    var currentGuild = ref.watch(currentGuildControllerProvider);
    Channel? currentChannel =
        ref.read(channelControllerProvider.notifier).getChannel();

    String channelName = "";
    if (currentChannel != null) {
      channelName = getChannelName(currentChannel);
    }

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
                      Expanded(
                          child: Text(
                              (currentGuild != null && currentChannel != null)
                                  ? "# $channelName"
                                  : "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.left,
                              style: Theme.of(context)
                                  .custom
                                  .textTheme
                                  .titleSmall
                                  .copyWith(
                                    color: Theme.of(context)
                                        .custom
                                        .colorTheme
                                        .textColor1,
                                  ))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: const Key("message-list"),
              controller: _scrollController,
              itemCount: messages.length,
              reverse: true,
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (context, index) {
                bool showAuthor = true;

                if (index + 1 < messages.length) {
                  showAuthor = messages[index + 1].author.id ==
                      messages[index].author.id;
                } else {
                  showAuthor = false;
                }
                var key = Key(messages[index].id.value.toString());

                var box = MessageBox(
                  key: key,
                );
                box.setMessage(messages[index]);
                box.setShowSenderInfo(!showAuthor);

                return box;
              },
            ),
          ),
          MessageBar(currentChannel: currentChannel),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          ),
          const KeyboardBuffer()
        ],
      ),
    );
  }
}

class KeyboardBuffer extends StatefulWidget {
  const KeyboardBuffer({super.key});

  @override
  State<KeyboardBuffer> createState() => _KeyboardBufferState();
}

class _KeyboardBufferState extends State<KeyboardBuffer> {
  @override
  Widget build(BuildContext context) {
    return keyboard_size.Consumer<ScreenHeight>(
      builder: (context, screenHeight, child) {
        return SizedBox(
          height: screenHeight.keyboardHeight,
        );
      },
    );
  }
}

class MessageBar extends ConsumerStatefulWidget {
  late Channel? currentChannel;

  MessageBar({super.key, required this.currentChannel});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageBarState();
}

String getChannelName(Channel channel) {
  if (channel.type == ChannelType.guildText) {
    return (channel as GuildTextChannel).name;
  } else {
    return "Name not implemented.";
  }
}

class _MessageBarState extends ConsumerState<MessageBar> {
  Widget _messageBarIcon(Icon icon, void Function() onPressed,
      {Color? backgroundColor}) {
    return Padding(
      padding: const EdgeInsets.all(8),
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
    return Container(
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
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                            'Message #${(widget.currentChannel != null) ? getChannelName(widget.currentChannel!) : ""}',
                        hintStyle: const TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                      style: Theme.of(context).custom.textTheme.bodyText1,
                    )),
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
            backgroundColor: Theme.of(context).custom.colorTheme.blurpleColor,
          ),
        ],
      ),
    );
  }
}

class MessageBox extends ConsumerStatefulWidget {
  Message? message;
  bool showSenderInfo = true;
  MessageBox({super.key});

  @override
  ConsumerState<MessageBox> createState() => _MessageBoxState();

  void setMessage(Message message) {
    this.message = message;
  }

  void setShowSenderInfo(bool showSenderInfo) {
    this.showSenderInfo = showSenderInfo;
  }
}

class _MessageBoxState extends ConsumerState<MessageBox> {
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

  void launchCustomUrl(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var embeds = widget.message!.embeds;

    String name = widget.message!.author.username;

    Color textColor = Colors.white;
    String? roleIconUrl;

    var member = ref.watch(getMemberProvider(widget.message!.author.id));
    var roles = ref.watch(getGuildRolesProvider).valueOrNull ?? [];

    member.when(
      data: (member) {
        name = member?.nick ?? name;
        Role? topRole;
        Role? topEmojiRole;
        for (PartialRole partialRole in member!.roles) {
          Role? role = roles.firstWhereOrNull((role) => partialRole.id == role!.id);
          if (role == null) {
            continue;
          }
          topRole ??= role;

          if (role.icon != null) {
              topEmojiRole ??= role;
              if (topEmojiRole.position < role.position) {
                topEmojiRole = role;
              }
          }

          if (topRole.position < role.position) {
            topRole = role;
          }

          
          var tc = topRole.color;
          roleIconUrl = topEmojiRole?.icon?.url.toString();
          if (tc.value != 0) textColor = Color.fromRGBO(tc.r, tc.g, tc.b, 1);
        }
        
      },
      loading: () {
      },
      error: (error, stack) {
      },
    );


    return Column(
      children: [
        SizedBox(
          height: widget.showSenderInfo ? 16 : 0,
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: const BorderSide(
              color: Color.fromARGB(0, 255, 255, 255),
              width: 0.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          onPressed: () {
            
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (widget.showSenderInfo == true)
                  ? Avatar(key: Key(widget.message!.author.avatarHash ?? ""), author: widget.message!.author)
                  : const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 45,
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
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Text(
                                    name,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                  // emoji
                                  if (roleIconUrl != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6, top: 2),
                                      child: Image.network(
                                        roleIconUrl!,
                                        width: 22,
                                        height: 22,
                                      ),
                                    ),
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
                        highlightBuilder: (text, language, infoString) {
                          final prism = Prism(
                              style: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const PrismStyle.dark()
                                  : const PrismStyle());

                          try {
                            var rendered =
                                prism.render(text, language ?? 'plain');
                            return rendered;
                          } catch (e) {
                            // fixes grammar issue?
                            return <TextSpan>[TextSpan(text: text)];
                          }
                        },
                        onTapLink: (href, title) {
                          print("Tapped link: $href");
                          launchUrl(Uri.parse(href!),
                              mode: LaunchMode.externalApplication);
                        },
                        styleSheet: MarkdownStyle(
                          paragraph:
                              Theme.of(context).custom.textTheme.bodyText1,
                          codeBlock:
                              Theme.of(context).custom.textTheme.bodyText1,
                          codeblockDecoration: BoxDecoration(
                              color: Theme.of(context)
                                  .custom
                                  .colorTheme
                                  .cardSelected,
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                  // add per embed
                  for (var embed in embeds)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: EmbedWidget(
                        embed: embed,
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
