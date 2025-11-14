import 'package:firebridge/src/builders/channel/thread.dart';
import 'package:firebridge/src/builders/invite.dart';
import 'package:firebridge/src/builders/permission_overwrite.dart';
import 'package:firebridge/src/models/channel/channel.dart';
import 'package:firebridge/src/models/channel/guild_channel.dart';
import 'package:firebridge/src/models/channel/text_channel.dart';
import 'package:firebridge/src/models/channel/has_threads_channel.dart';
import 'package:firebridge/src/models/channel/thread.dart';
import 'package:firebridge/src/models/channel/thread_list.dart';
import 'package:firebridge/src/models/guild/guild.dart';
import 'package:firebridge/src/models/invite/invite.dart';
import 'package:firebridge/src/models/invite/invite_metadata.dart';
import 'package:firebridge/src/models/message/message.dart';
import 'package:firebridge/src/models/permission_overwrite.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/models/webhook.dart';

/// {@template guild_announcement_channel}
/// An announcement channel in a [Guild].
/// {@endtemplate}
class GuildAnnouncementChannel extends TextChannel
    implements GuildChannel, HasThreadsChannel {
  /// The topic of this channel.
  final String? topic;

  @override
  final Duration defaultAutoArchiveDuration;

  @override
  final Duration? defaultThreadRateLimitPerUser;

  @override
  final Snowflake guildId;

  @override
  final bool isNsfw;

  @override
  final Snowflake? lastMessageId;

  @override
  final DateTime? lastPinTimestamp;

  @override
  final String name;

  @override
  final Snowflake? parentId;

  @override
  final List<PermissionOverwrite> permissionOverwrites;

  @override
  final int position;

  @override
  final Duration? rateLimitPerUser;

  @override
  ChannelType get type => ChannelType.guildAnnouncement;

  /// {@macro guild_announcement_channel}
  /// @nodoc
  GuildAnnouncementChannel({
    required super.id,
    required super.manager,
    required this.topic,
    required this.defaultAutoArchiveDuration,
    required this.defaultThreadRateLimitPerUser,
    required this.guildId,
    required this.isNsfw,
    required this.lastMessageId,
    required this.lastPinTimestamp,
    required this.name,
    required this.parentId,
    required this.permissionOverwrites,
    required this.position,
    required this.rateLimitPerUser,
  });

  @override
  PartialGuild get guild => manager.client.guilds[guildId];

  @override
  PartialMessage? get lastMessage =>
      lastMessageId == null ? null : messages[lastMessageId!];

  @override
  PartialChannel? get parent =>
      parentId == null ? null : manager.client.channels[parentId!];

  @override
  Future<Thread> createThread(ThreadBuilder builder) =>
      manager.createThread(id, builder);

  @override
  Future<Thread> createThreadFromMessage(
          Snowflake messageId, ThreadFromMessageBuilder builder) =>
      manager.createThreadFromMessage(id, messageId, builder);

  @override
  Future<void> deletePermissionOverwrite(Snowflake id) =>
      manager.deletePermissionOverwrite(this.id, id);

  @override
  Future<ThreadList> listPrivateArchivedThreads(
          {DateTime? before, int? limit}) =>
      manager.listPrivateArchivedThreads(id, before: before, limit: limit);

  @override
  Future<ThreadList> listPublicArchivedThreads(
          {DateTime? before, int? limit}) =>
      manager.listPublicArchivedThreads(id, before: before, limit: limit);

  @override
  Future<ThreadList> listJoinedPrivateArchivedThreads(
          {DateTime? before, int? limit}) =>
      manager.listJoinedPrivateArchivedThreads(id,
          before: before, limit: limit);

  @override
  Future<void> updatePermissionOverwrite(PermissionOverwriteBuilder builder) =>
      manager.updatePermissionOverwrite(id, builder);

  @override
  Future<List<Webhook>> fetchWebhooks() =>
      manager.client.webhooks.fetchChannelWebhooks(id);

  @override
  Future<List<InviteWithMetadata>> listInvites() => manager.listInvites(id);

  @override
  Future<Invite> createInvite(InviteBuilder builder,
          {String? auditLogReason}) =>
      manager.createInvite(id, builder, auditLogReason: auditLogReason);
}
