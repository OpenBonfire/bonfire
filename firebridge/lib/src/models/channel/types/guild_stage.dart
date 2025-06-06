import 'package:firebridge/src/builders/invite.dart';
import 'package:firebridge/src/builders/permission_overwrite.dart';
import 'package:firebridge/src/models/channel/channel.dart';
import 'package:firebridge/src/models/channel/guild_channel.dart';
import 'package:firebridge/src/models/channel/text_channel.dart';
import 'package:firebridge/src/models/channel/voice_channel.dart';
import 'package:firebridge/src/models/guild/guild.dart';
import 'package:firebridge/src/models/invite/invite.dart';
import 'package:firebridge/src/models/invite/invite_metadata.dart';
import 'package:firebridge/src/models/message/message.dart';
import 'package:firebridge/src/models/permission_overwrite.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/models/webhook.dart';

/// {@template guild_stage_channel}
/// A stage channel.
/// {@endtemplate}
class GuildStageChannel extends TextChannel
    implements VoiceChannel, GuildChannel {
  @override
  final int bitrate;

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
  final String? rtcRegion;

  @override
  final int? userLimit;

  @override
  final VideoQualityMode videoQualityMode;

  @override
  ChannelType get type => ChannelType.guildStageVoice;

  /// {@macro guild_stage_channel}
  /// @nodoc
  GuildStageChannel({
    required super.id,
    required super.manager,
    required this.bitrate,
    required this.guildId,
    required this.isNsfw,
    required this.lastMessageId,
    required this.lastPinTimestamp,
    required this.name,
    required this.parentId,
    required this.permissionOverwrites,
    required this.position,
    required this.rateLimitPerUser,
    required this.rtcRegion,
    required this.userLimit,
    required this.videoQualityMode,
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
  Future<void> deletePermissionOverwrite(Snowflake id) =>
      manager.deletePermissionOverwrite(this.id, id);

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
