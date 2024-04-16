import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyxx/nyxx.dart' as nyxx;
import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:bonfire/colors.dart';
import 'package:bonfire/globals.dart';
import 'package:bonfire/network/message.dart';
import 'package:bonfire/style.dart';
import 'package:bonfire/styles/styles.dart';
import 'package:bonfire/views/home/signal/channel.dart';

class Messages extends StatefulWidget {
  Messages({Key? key});

  nyxx.GuildChannel? channel;

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List<nyxx.Message> messages = [];

  @override
  void initState() {
    super.initState();
    MessageService().initSubscription();
    MessageService().eventStream.listen((event) {
      if (globalChannel == null) {
        return;
      }
      if (event.message.channel.id.value == globalChannel!.id.value) {
        setState(() {
          messages.insert(0, event.message);
        });
      }
    });

    channelSignal.subscribe((channel) {
      if (channel != null) {
        setState(() {
          widget.channel = channel;
        });
        if (channel.type == nyxx.ChannelType.guildText) {
          var _channel = channel as nyxx.GuildTextChannel;
          _channel.messages.fetchMany(limit: 100).then((value) {
            setState(() {
              messages = value.toList();
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MessageListView(messages: messages),
        MessageBar(),
      ],
    );
  }
}

class MessageListView extends StatefulWidget {
  final List<nyxx.Message> messages;

  MessageListView({Key? key, required this.messages});

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late ScrollController _scrollController;

  bool currentKeyboardState = false;
  int maxKeyboardSize = 200;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addObserver(this);
    KeyboardVisibilityController().onChange.listen((newState) {
      if (currentKeyboardState != newState) {
        setState(() {
          currentKeyboardState = newState;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (MediaQuery.of(context).viewInsets.bottom > maxKeyboardSize) {
      setState(() {
        maxKeyboardSize = MediaQuery.of(context).viewInsets.bottom.toInt();
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedContainer(
      // I really want to have an animated container, but it's just to laggy when resizing
      duration: const Duration(milliseconds: 0),
      height: currentKeyboardState
          ? (MediaQuery.of(context).size.height - maxKeyboardSize - 60)
          : MediaQuery.of(context).size.height - 60,
      child: AnimatedMessagesList(
        messages: widget.messages,
        scrollController: _scrollController,
      ),
    );
  }
}

class AnimatedMessagesList extends StatefulWidget {
  final List<nyxx.Message> messages;
  final ScrollController scrollController;

  AnimatedMessagesList(
      {Key? key, required this.messages, required this.scrollController})
      : super(key: key ?? UniqueKey());

  @override
  _AnimatedMessagesListState createState() => _AnimatedMessagesListState();
}

class _AnimatedMessagesListState extends State<AnimatedMessagesList> {
  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: widget.key,
      controller: widget.scrollController,
      reverse: true,
      initialItemCount: widget.messages.length,
      itemBuilder: (context, index, animation) {
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(0, 5),
              end: Offset.zero,
            ),
          ),
          child: MessageBox(
            key: ValueKey(widget.messages[index].id),
            message: widget.messages[index],
          ),
        );
      },
    );
  }
}

class MessageBar extends StatelessWidget {
  MessageBar({Key? key});
  final fieldText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      decoration: const BoxDecoration(
        color: foreground,
        border:
            Border.symmetric(horizontal: BorderSide(color: foregroundBright)),
      ),
      child: TextField(
        controller: fieldText,
        style: GoogleFonts.inriaSans(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Message',
          hintStyle: GoogleFonts.inriaSans(color: Colors.white),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            if (channelSignal.value != null) {
              var channel = channelSignal.value as nyxx.GuildTextChannel;
              channel.sendMessage(nyxx.MessageBuilder(content: value));
              fieldText.clear();
            }
          }
        },
        onEditingComplete: () {},
      ),
    );
  }
}

class MessageBox extends StatefulWidget {
  final nyxx.Message message;

  MessageBox({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

HashMap<int, Widget> messageWidgets = HashMap<int, Widget>();

class _MessageBoxState extends State<MessageBox>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<ImageProvider> fetchPfpImage(nyxx.CdnAsset? icon) async {
    if (icon != null) {
      FileInfo? fromCache =
          await DefaultCacheManager().getFileFromCache(icon.hash);

      if (fromCache != null) {
        return MemoryImage(fromCache.file.readAsBytesSync());
      }

      var bytes = await icon.fetch();
      String cacheKey = icon.hash;
      await DefaultCacheManager().putFile(cacheKey, bytes);
      return MemoryImage(bytes);
    }

    return const AssetImage('assets/placeholder.png');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return OutlinedButton(
      style: ButtonStyle(
        alignment: Alignment.centerLeft,
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        side: MaterialStateProperty.all<BorderSide>(
          const BorderSide(
            width: 0,
            color: Color.fromARGB(0, 77, 77, 77),
          ),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return primaryColor;
            }
            return Colors.transparent;
          },
        ),
      ),
      onPressed: () {
        print(messageWidgets.entries.length);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: (messageWidgets[widget.message.id.value] == null)
                  ? FutureBuilder<ImageProvider<Object>>(
                      future: fetchPfpImage(widget.message.author.avatar),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          var box = SizedBox(
                            child: CircleAvatar(
                              key: ValueKey(widget.message.id.value),
                              minRadius: 22,
                              maxRadius: 22,
                              backgroundImage: snapshot.data,
                              backgroundColor: Colors.transparent,
                            ),
                          );
                          messageWidgets[widget.message.id.value] = box;
                          return box;
                        } else {
                          return const CircleAvatar(
                            minRadius: 22,
                            maxRadius: 22,
                            backgroundColor: Colors.transparent,
                          );
                        }
                      },
                    )
                  : messageWidgets[widget.message.id.value],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 0),
                  child: Text(
                    widget.message.author.username,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inriaSans(
                      color: const Color.fromARGB(189, 255, 255, 255),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 126,
                    child: MarkdownViewer(
                      widget.message.content,
                      enableTaskList: true,
                      enableSuperscript: false,
                      enableSubscript: false,
                      enableFootnote: false,
                      enableImageSize: false,
                      enableKbd: false,
                      syntaxExtensions: const [],
                      elementBuilders: const [],
                      styleSheet: MarkdownStyle(paragraph: inputBoxStyle),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
