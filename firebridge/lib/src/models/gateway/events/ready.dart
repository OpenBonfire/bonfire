import 'package:firebridge/src/models/application.dart';
import 'package:firebridge/src/models/channel/channel.dart';
import 'package:firebridge/src/models/channel/types/dm.dart';
import 'package:firebridge/src/models/channel/types/group_dm.dart';
import 'package:firebridge/src/models/gateway/event.dart';
import 'package:firebridge/src/models/gateway/events/presence.dart';
import 'package:firebridge/src/models/guild/guild.dart';
import 'package:firebridge/src/models/user/relationship.dart';
import 'package:firebridge/src/models/user/settings/private_channel.dart';
import 'package:firebridge/src/models/user/settings/read_state.dart';
import 'package:firebridge/src/models/user/settings/user_guild_settings.dart';
import 'package:firebridge/src/models/user/settings/user_settings.dart';
import 'package:firebridge/src/models/user/user.dart';

/// {@template ready_event}
/// Emitted when the client's Gateway session is established.
/// {@endtemplate}
class ReadyEvent extends DispatchEvent {
  /// The version of the API being used.
  final int version;

  /// The current client's user.
  final User user;

  /// A list of guilds the user is in.
  final List<Guild> guilds;

  /// The ID of the Gateway session.
  final String sessionId;

  /// The URL to use when resuming the Gateway session.
  final Uri gatewayResumeUrl;

  /// The ID of the shard.
  final int? shardId;

  /// The total number of shards.
  final int? totalShards;

  /// The user's settings.
  final UserSettings userSettings;

  /// The user's guild settings.
  final List<UserGuildSettings> userGuildSettings;

  /// The user's read states of guilds.
  final List<ReadState> readStates;

  /// The client's private channel.
  final List<Channel> privateChannels;

  /// The client's presences.
  final List<PresenceUpdateEvent> presences;

  /// The client's application.
  final PartialApplication? application;

  /// The client's relationships.
  final List<Relationship> relationships;

  /// {@macro ready_event}
  /// @nodoc
  ReadyEvent({
    required super.gateway,
    required this.version,
    required this.user,
    required this.guilds,
    required this.sessionId,
    required this.gatewayResumeUrl,
    required this.shardId,
    required this.totalShards,
    required this.userSettings,
    required this.userGuildSettings,
    required this.readStates,
    required this.privateChannels,
    required this.presences,
    required this.relationships,
    this.application,
  });
}

/// {@template resumed_event}
/// Emitted when
/// {@endtemplate}
class ResumedEvent extends DispatchEvent {
  /// {@macro resumed_event}
  /// @nodoc
  ResumedEvent({required super.gateway});
}
