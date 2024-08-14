import 'dart:async';

import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/views/components/bar.dart';
import 'package:bonfire/features/messaging/views/components/box/box.dart';
import 'package:bonfire/features/messaging/views/components/box/channel_header.dart';
import 'package:bonfire/features/messaging/views/components/keyboard_buffer.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/shared/utils/platform.dart';

String getChannelName(Channel channel) {
  if (channel is DmChannel) {
    String name = "";
    for (var recipient in channel.recipients) {
      name += "${recipient.globalName ?? recipient.username}, ";
    }

    return name.substring(0, name.length - 2);
  }
  return (channel as GuildChannel).name;
}

class MessageView extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  const MessageView(
      {super.key, required this.guildId, required this.channelId});

  @override
  ConsumerState<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageView> {
  final ScrollController _scrollController = ScrollController();
  List<Message> loadedMessages = [];
  Message? lastScrollMessage;
  Message? firstBatchLastMessage;
  Logger logger = Logger("MessageView");
  bool _isLoadingMore = false;
  bool sentInitialAck = false;

  // void _routeListener() {}

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // GoRouter.of(context).routerDelegate.addListener(_routeListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == 0) {
      loadedMessages.first.manager.acknowledge(loadedMessages.first.id);
    }
    if (!_isLoadingMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 2000) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (firstBatchLastMessage == null) return;
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    lastScrollMessage = lastScrollMessage ?? firstBatchLastMessage!;
    List<Message>? recents = await ref
        .read(messagesProvider(widget.channelId).notifier)
        .fetchMessages(before: lastScrollMessage!, limit: 50);

    if (recents.isNotEmpty) {
      if (lastScrollMessage?.id != recents.last.id) {
        setState(() {
          lastScrollMessage = recents.last;
        });
      }
    }
    _isLoadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    var messageOutput = ref.watch(messagesProvider(widget.channelId));

    messageOutput.when(
      data: (messages) {
        loadedMessages = messages ?? [];
      },
      loading: () {
        // loadedMessages = [];
      },
      error: (error, stack) {
        print("errored!");
        print(stack);
        print(error);

        loadedMessages = [];
      },
    );

    String channelName = "";
    Channel? channel =
        ref.watch(channelControllerProvider(widget.channelId)).valueOrNull;

    Guild? guild =
        ref.watch(guildControllerProvider(widget.guildId)).valueOrNull;

    if (channel == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    channelName = getChannelName(channel);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ListView.custom(
                  controller: _scrollController,
                  reverse: true,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 12),
                  childrenDelegate: SliverChildBuilderDelegate(
                    childCount:
                        loadedMessages.length + (isSmartwatch(context) ? 1 : 0),
                    findChildIndexCallback: (Key key) {
                      final ValueKey<BigInt> valueKey = key as ValueKey<BigInt>;
                      var idx = loadedMessages.indexWhere(
                          (message) => message.id.value == valueKey.value);
                      if (idx == -1) return null;
                      return idx;
                    },
                    (context, index) {
                      if (isSmartwatch(context) && index == 0) {
                        return MessageBar(
                          guildId: guild?.id ?? Snowflake.zero,
                          channel: channel,
                        );
                      }

                      final messageIndex =
                          isSmartwatch(context) ? index - 1 : index;
                      bool showAuthor = true;

                      if (messageIndex + 1 < loadedMessages.length) {
                        Message currentMessage = loadedMessages[messageIndex];
                        Message lastMessage = loadedMessages[messageIndex + 1];

                        showAuthor =
                            lastMessage.author.id != currentMessage.author.id;

                        if (currentMessage.timestamp
                                .difference(lastMessage.timestamp)
                                .inMinutes >
                            5) {
                          showAuthor = true;
                        }
                        if (currentMessage.referencedMessage != null) {
                          showAuthor = true;
                        }
                      } else {
                        showAuthor = true;
                      }
                      if (messageIndex == loadedMessages.length - 1 &&
                          lastScrollMessage == null) {
                        firstBatchLastMessage = loadedMessages[messageIndex];
                      }

                      return MessageBox(
                        key: ValueKey(loadedMessages[messageIndex].id.value),
                        guildId: guild?.id ?? Snowflake.zero,
                        channel: channel,
                        messageId: loadedMessages[messageIndex].id,
                        showSenderInfo: showAuthor,
                      );
                    },
                  ),
                ),
                if (!isSmartwatch(context))
                  ChannelHeader(channelName: channelName),
              ],
            ),
          ),
          if (!isSmartwatch(context))
            MessageBar(
              guildId: guild?.id ?? Snowflake.zero,
              channel: channel,
            ),
          if (!isSmartwatch(context))
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          if (!isSmartwatch(context)) const KeyboardBuffer()
        ],
      ),
    );
  }
}
