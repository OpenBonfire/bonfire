import 'dart:async';

import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/components/bar.dart';
import 'package:bonfire/features/messaging/components/box/box.dart';
import 'package:bonfire/features/messaging/components/channel_header.dart';
import 'package:bonfire/features/messaging/components/box/message_loading_animation.dart';
import 'package:bonfire/features/messaging/components/keyboard_buffer.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/shared/utils/platform.dart';

class MessageList extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  final Snowflake? threadId;
  const MessageList({
    super.key,
    required this.guildId,
    required this.channelId,
    this.threadId,
  });

  @override
  ConsumerState<MessageList> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageList>
    with SingleTickerProviderStateMixin {
  Timer? _debounceTimer;
  final ScrollController _scrollController = ScrollController();
  final Logger _logger = Logger("MessageView");
  bool _isLoadingMore = false;
  bool _isLoadingNewer = false;
  Message? _oldestLoadedMessage;
  Message? _newestLoadedMessage;
  double? _previousMaxScrollExtent;
  Snowflake? _lastChannelId;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print("is init so refresh messages?!");
    _scrollController.addListener(_scrollListener);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    Stream<ReadyEvent>? listener;

    ref.listenManual(authProvider, (_, state) {
      if (state is AuthUser) {
        listener = state.client.onReady;
        listener!.listen((event) {
          _refreshForChannelChange();
        });
      }
    });
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.channelId != widget.channelId) {
      _scrollController.jumpTo(0);
      _refreshForChannelChange();
    }
  }

  void _refreshForChannelChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesProvider(widget.channelId).notifier).refreshMessages();
      _oldestLoadedMessage = null;
      _newestLoadedMessage = null;
      _lastChannelId = widget.channelId;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fadeController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    // Acknowledge messages when scrolled to top (newest messages)
    if (_scrollController.position.pixels == 0) {
      final messages = ref.read(messagesProvider(widget.channelId)).valueOrNull;
      if (messages != null && messages.isNotEmpty) {
        messages.first.manager.acknowledge(messages.first.id);
      }
    }

    // Load older messages when approaching bottom
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300) {
      if (!_isLoadingMore && _oldestLoadedMessage != null) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
          _loadOlderMessages();
        });
      }
    }

    // Load newer messages when near the top (except at the very top)
    if (_scrollController.hasClients &&
        _scrollController.position.pixels <= 300 &&
        _scrollController.position.pixels > 0) {
      if (!_isLoadingNewer && _newestLoadedMessage != null) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
          _loadNewerMessages();
        });
      }
    }

    // Save the current max scroll extent to maintain position when new messages load
    if (_scrollController.hasClients) {
      _previousMaxScrollExtent = _scrollController.position.maxScrollExtent;
    }
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingMore || _oldestLoadedMessage == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await ref
          .read(messagesProvider(widget.channelId).notifier)
          .fetchMessagesBefore(_oldestLoadedMessage!, limit: 50);

      _updateOldestAndNewestMessages();
    } catch (e) {
      _logger.severe("Error loading older messages", e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadNewerMessages() async {
    if (_isLoadingNewer || _newestLoadedMessage == null) return;

    setState(() {
      _isLoadingNewer = true;
    });

    try {
      await ref
          .read(messagesProvider(widget.channelId).notifier)
          .fetchMessagesAfter(_newestLoadedMessage!, limit: 30);

      _updateOldestAndNewestMessages();
    } catch (e) {
      _logger.severe("Error loading newer messages", e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingNewer = false;
        });
      }
    }
  }

  void _updateOldestAndNewestMessages() {
    final messages = ref.read(messagesProvider(widget.channelId)).valueOrNull;
    if (messages == null || messages.isEmpty) return;

    // Since messages are sorted newest first, first is newest and last is oldest
    _newestLoadedMessage = messages.first;
    _oldestLoadedMessage = messages.last;

    // If we have a previous max scroll position, try to maintain scroll position
    if (_previousMaxScrollExtent != null &&
        _scrollController.hasClients &&
        _previousMaxScrollExtent !=
            _scrollController.position.maxScrollExtent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final delta = _scrollController.position.maxScrollExtent -
              _previousMaxScrollExtent!;
          if (delta > 0) {
            // _scrollController.jumpTo(_scrollController.offset + delta);
          }
        }
      });
    }
  }

  Widget _buildMessageList() {
    final messages =
        ref.watch(messagesProvider(widget.channelId)).valueOrNull ?? [];

    // Update oldest and newest message references
    if (messages.isNotEmpty) {
      _newestLoadedMessage = messages.first;
      _oldestLoadedMessage = messages.last;
    }

    return ListView.custom(
      controller: _scrollController,
      reverse: true,
      shrinkWrap: true,
      padding: EdgeInsets.only(
        bottom: 12,
        top: isSmartwatch(context)
            ? 0
            : 50 +
                MediaQuery.of(context)
                    .viewPadding
                    .top, // add the height of the channel header
        left: 0,
        right: 0,
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        childCount: messages.length + (isSmartwatch(context) ? 1 : 0),
        findChildIndexCallback: (Key key) {
          final ValueKey<BigInt> valueKey = key as ValueKey<BigInt>;
          var idx = messages
              .indexWhere((message) => message.id.value == valueKey.value);
          if (idx == -1) return null;
          return idx;
        },
        (context, index) {
          final channel =
              ref.watch(channelControllerProvider(widget.channelId));

          if (channel == null) return const SizedBox.shrink();
          if (isSmartwatch(context) && index == 0) {
            return MessageBar(
                guildId:
                    ref.read(guildControllerProvider(widget.guildId))?.id ??
                        Snowflake.zero,
                channel: channel);
          }

          final messageIndex = isSmartwatch(context) ? index - 1 : index;
          bool showAuthor = true;

          if (messageIndex + 1 < messages.length) {
            Message currentMessage = messages[messageIndex];
            Message lastMessage = messages[messageIndex + 1];

            showAuthor = lastMessage.author.id != currentMessage.author.id;

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

          return MessageBox(
            key: ValueKey(messages[messageIndex].id.value),
            guildId: ref.read(guildControllerProvider(widget.guildId))?.id ??
                Snowflake.zero,
            channel: channel,
            messageId: messages[messageIndex].id,
            showSenderInfo: showAuthor,
            scrollController: _scrollController,
          );
        },
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      reverse: true,
      itemCount: 10, // Show 10 loading placeholders
      itemBuilder: (context, index) => const MessageLoadingAnimation(),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Error loading messages: ${error.toString()}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(messagesProvider(widget.channelId).notifier)
                  .refreshMessages();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageOutput = ref.watch(messagesProvider(widget.channelId));

    // Check if channel changed
    if (_lastChannelId != widget.channelId) {
      _lastChannelId = widget.channelId;
      _refreshForChannelChange();
    }

    Widget content = Container();

    messageOutput.when(
      data: (messages) {
        if (messages != null && messages.isNotEmpty) {
          _fadeController.forward();
          content = _buildMessageList();
        } else {
          content = const Center(
            child: Text('No messages in this channel'),
          );
        }
      },
      loading: () {
        _fadeController.reverse();
        content = _buildLoadingList();
      },
      error: (error, stack) {
        _logger.severe("Error loading messages", error, stack);
        _fadeController.forward();
        content = _buildErrorWidget(error);
      },
    );

    final channel = ref.watch(channelControllerProvider(widget.channelId));
    final guild = ref.watch(guildControllerProvider(widget.guildId));

    if (channel == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FadeTransition(
                    opacity: _fadeAnimation,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: content,
                    )),
                if (!isSmartwatch(context))
                  ChannelHeader(
                    channelId: channel.id,
                  ),
              ],
            ),
          ),
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

class NoMessageSendPermissionPlaceholder extends StatelessWidget {
  const NoMessageSendPermissionPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.background));
  }
}
