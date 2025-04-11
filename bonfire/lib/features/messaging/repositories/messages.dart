import 'dart:async';

import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/typing.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/guild/controllers/role.dart';
import 'package:bonfire/features/guild/controllers/roles.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/features/messaging/controllers/message.dart';
import 'package:bonfire/features/messaging/controllers/reply.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages.g.dart';

enum MessageFetchDirection {
  before,
  after,
  around,
}

/// Message provider for fetching messages from the Discord API
@riverpod
class Messages extends _$Messages {
  AuthUser? _user;
  final Map<String, Message> _messageCache = {};
  Timer? _authDebounceTimer;
  bool _isInitialLoad = true;
  final Logger _logger = Logger("MessagesProvider");

  @override
  Future<List<Message>?> build(Snowflake channelId) async {
    final auth = ref.watch(authProvider);

    ref.onDispose(() {
      _authDebounceTimer?.cancel();
    });

    if (auth is AuthUser) {
      _user = auth;

      // I think this is kinda useless but we'll see I guess
      if (!_isInitialLoad && _messageCache.isNotEmpty) {
        _authDebounceTimer?.cancel();
        _authDebounceTimer = Timer(const Duration(milliseconds: 1000), () {
          _messageCache.clear();
          _fetchInitialMessages();
        });
      } else {
        return _fetchInitialMessages();
      }
    } else {
      _user = null;
      _messageCache.clear();
      return null;
    }

    if (_messageCache.isNotEmpty) {
      return _getSortedMessages();
    }

    return null;
  }

  /// Returns messages sorted by timestamp, newest first
  List<Message> _getSortedMessages() {
    final messages = _messageCache.values.toList();
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return messages;
  }

  /// Fetch initial messages for the channel
  Future<List<Message>?> _fetchInitialMessages() async {
    _isInitialLoad = false;

    if (_user == null || channelId == Snowflake.zero) {
      return [];
    }

    // Check for channel access permissions
    if (!await _hasChannelAccess()) {
      return [];
    }

    try {
      final messages = await _fetchMessages(limit: 50);

      if (messages.isNotEmpty) {
        await messages.first.manager.acknowledge(messages.first.id);
      }

      return _getSortedMessages();
    } catch (e, stack) {
      _logger.severe("Error fetching initial messages", e, stack);
      return [];
    }
  }

  /// Check if the user has access to read messages in this channel
  Future<bool> _hasChannelAccess() async {
    final channel = ref.read(channelControllerProvider(channelId));
    if (channel == null) {
      _logger.warning("Tried to request messages from a null channel.");
      return false;
    }

    if (channel is! TextChannel) {
      _logger.warning("Channel ${channel.id} is not a text channel");
      return false;
    }

    if (channel is GuildChannel) {
      final guild =
          ref.read(guildControllerProvider((channel as GuildChannel).guildId));
      if (guild == null) return false;

      final roleIds =
          ref.read(rolesControllerProvider((channel as GuildChannel).guildId));
      if (roleIds == null) return false;

      final roles = roleIds
          .map((roleId) => ref.read(roleControllerProvider(roleId)))
          .whereType<Role>()
          .toList();

      final selfMember = await guild.members.get(_user!.client.user.id);
      final permissions = await (channel as GuildChannel)
          .computePermissionsForMemberWithGuildAndRoles(
              selfMember, guild, roles);

      if (!permissions.canReadMessageHistory) {
        _logger.warning(
            "No permission to read message history in channel ${channel.id}");
        return false;
      }
    }

    return true;
  }

  /// Fetch messages with specified parameters
  Future<List<Message>> _fetchMessages({
    MessageFetchDirection direction = MessageFetchDirection.before,
    Snowflake? reference,
    int limit = 50,
    bool updateState = true,
    bool disableAck = false,
  }) async {
    if (_user == null) return [];

    final channel = ref.read(channelControllerProvider(channelId));
    if (channel == null || channel is! TextChannel) return [];

    Snowflake? before, after, around;
    switch (direction) {
      case MessageFetchDirection.before:
        before = reference;
        break;
      case MessageFetchDirection.after:
        after = reference;
        break;
      case MessageFetchDirection.around:
        around = reference;
        break;
    }

    try {
      final messages = await channel.messages.fetchMany(
        limit: limit,
        before: before,
        after: after,
        around: around,
      );
      for (final message in messages) {
        _cacheMessage(message);
      }

      if (!disableAck &&
          before == null &&
          after == null &&
          around == null &&
          messages.isNotEmpty) {
        await messages.first.manager.acknowledge(messages.first.id);
      }

      if (updateState) {
        state = AsyncValue.data(_getSortedMessages());
      }

      return messages.toList();
    } catch (e, stack) {
      _logger.severe("Error fetching messages", e, stack);
      return [];
    }
  }

  void _cacheMessage(Message message) {
    _messageCache[message.id.toString()] = message;
    ref
        .read(messageControllerProvider(message.id).notifier)
        .setMessage(message);
  }

  /// Fetch messages before a specific message
  Future<List<Message>> fetchMessagesBefore(Message reference,
      {int limit = 50}) async {
    return await _fetchMessages(
      direction: MessageFetchDirection.before,
      reference: reference.id,
      limit: limit,
    );
  }

  /// Fetch messages after a specific message
  Future<List<Message>> fetchMessagesAfter(Message reference,
      {int limit = 50}) async {
    return await _fetchMessages(
      direction: MessageFetchDirection.after,
      reference: reference.id,
      limit: limit,
    );
  }

  /// Fetch messages around a specific message
  Future<List<Message>> fetchMessagesAround(Snowflake reference,
      {int limit = 50}) async {
    return await _fetchMessages(
      direction: MessageFetchDirection.around,
      reference: reference,
      limit: limit,
    );
  }

  /// Process a new message
  void processMessage(Message message) async {
    if (message.channel.id != channelId) return;

    final channel = ref.read(channelControllerProvider(channelId));
    if (channel == null) return;

    // Update read state
    final ReadState? currentReadState =
        ref.read(channelReadStateProvider(message.channelId));

    int mentionCount = currentReadState?.mentionCount ?? 0;
    bool mentionsSelf = false;

    for (var mention in message.mentions) {
      if (mention.id == _user!.client.user.id) {
        mentionsSelf = true;
        break;
      }
    }

    if ((mentionsSelf || channel is DmChannel || channel is GroupDmChannel) &&
        message.author.id != _user!.client.user.id) {
      mentionCount++;
    }

    ref.read(channelReadStateProvider(message.channelId).notifier).setReadState(
          ReadState(
            channel: message.channel,
            lastMessage: message,
            lastPinTimestamp: currentReadState?.lastPinTimestamp,
            mentionCount: mentionCount,
            lastViewed: currentReadState?.lastViewed,
          ),
        );

    ref
        .read(typingProvider(channel.id).notifier)
        .cancelTyping(channelId, message.author.id);

    _cacheMessage(message);
    state = AsyncValue.data(_getSortedMessages());
  }

  /// Send a message to the channel
  Future<bool> sendMessage(
    Channel channel,
    String message, {
    List<AttachmentBuilder>? attachments,
  }) async {
    if (_user == null || channel is! TextChannel) return false;

    try {
      final Snowflake? replyTo = ref.read(replyControllerProvider)?.messageId;

      await channel.sendMessage(
        MessageBuilder(
          content: message,
          attachments: attachments,
          replyId: replyTo,
        ),
      );

      return true;
    } catch (e, stack) {
      _logger.severe("Error sending message", e, stack);
      return false;
    }
  }

  /// Refresh the messages in the channel
  Future<void> refreshMessages() async {
    _messageCache.clear();
    await _fetchInitialMessages();
  }
}
