import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/current_guild.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/views/components/bar.dart';
import 'package:bonfire/features/messaging/views/components/box/box.dart';
import 'package:bonfire/features/messaging/views/components/keyboard_buffer.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String getChannelName(Channel channel) {
  return (channel as GuildChannel).name;
}

class MessageView extends ConsumerStatefulWidget {
  const MessageView({super.key});

  @override
  ConsumerState<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageView> {
  final ScrollController _scrollController = ScrollController();
  Logger logger = Logger("MessageView");
  Map<int, MessageBox> boxMap = {};

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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 1000) {
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    ref.read(messagesProvider.notifier).fetchMoreMessages();
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
        color: Theme.of(context).custom.colorTheme.messageViewBackground,
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
              color: Theme.of(context).custom.colorTheme.messageViewBackground,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).custom.colorTheme.foreground,
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
                                        .channelHeaderText,
                                  ))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              // key: const Key("message-list"),
              controller: _scrollController,
              itemCount: messages.length,
              reverse: true,
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (context, index) {
                MessageBox? cachedBox = boxMap[messages[index].id.value];
                if (cachedBox != null) return cachedBox;

                bool showAuthor = true;

                if (index + 1 < messages.length) {
                  Message currentMessage = messages[index];
                  Message lastMessage = messages[index + 1];

                  showAuthor =
                      lastMessage.author.id == currentMessage.author.id;

                  if (currentMessage.timestamp
                          .difference(lastMessage.timestamp)
                          .inMinutes >
                      5) {
                    showAuthor = false;
                  }
                  if (currentMessage.referencedMessage != null) {
                    showAuthor = false;
                  }
                } else {
                  showAuthor = false;
                }

                MessageBox box = MessageBox(
                  key: ValueKey(messages[index].id.value.toString()),
                  message: messages[index],
                  showSenderInfo: !showAuthor,
                );

                boxMap[messages[index].id.value] = box;

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
