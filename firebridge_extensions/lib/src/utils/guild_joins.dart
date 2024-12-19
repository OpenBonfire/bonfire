import 'dart:async';

import 'package:firebridge/firebridge.dart';

/// A global instance of the [GuildJoins] plugin.
final guildJoins = GuildJoins();

/// Provides a way to know when the client joins or leaves a [Guild].
///
/// [NyxxGateway.onGuildCreate] and [NyxxGateway.onGuildDelete] can be
/// misleading, as although they do emit an event when the client is added to
/// or removed from a [Guild], they can also emit events in a variety of other
/// scenarios:
/// - When guilds become available or unavailable due to outages
/// - As part of session initialisation, to populate the cache with information
///   about the guild contained in the [ReadyEvent].
///
/// This plugin exposes two streams. [onGuildJoin] and [onGuildLeave], that
/// emit the same type of events as [NyxxGateway.onGuildCreate] and
/// [NyxxGateway.onGuildDelete], but only when the event is triggered by the
/// client joining or leaving a guild.
class GuildJoins extends NyxxPlugin<NyxxGateway> {
  final StreamController<UnavailableGuildCreateEvent> _onGuildJoinController =
      StreamController.broadcast();
  final StreamController<GuildDeleteEvent> _onGuildLeaveController =
      StreamController.broadcast();

  /// A stream of [UnavailableGuildCreateEvent] triggered by the client being
  /// added to a [Guild].
  ///
  /// As with [NyxxGateway.onGuildCreate], this stream normally emits
  /// [GuildCreateEvent]s, other than in the event of an outage.
  Stream<UnavailableGuildCreateEvent> get onGuildJoin =>
      _onGuildJoinController.stream;

  /// A stream of [GuildDeleteEvent]s triggered by the client being removed
  /// from a [Guild].
  Stream<GuildDeleteEvent> get onGuildLeave => _onGuildLeaveController.stream;

  @override
  NyxxPluginState<NyxxGateway, GuildJoins> createState() =>
      _GuildJoinsState(this);
}

class _GuildJoinsState extends NyxxPluginState<NyxxGateway, GuildJoins> {
  final Set<Snowflake> _currentGuildIds = {};

  _GuildJoinsState(super.plugin);

  @override
  void afterConnect(NyxxGateway client) {
    super.afterConnect(client);

    client.onReady.listen(
      (event) => _currentGuildIds.addAll(event.guilds.map((guild) => guild.id)),
    );

    client.onGuildCreate.listen((event) {
      if (_currentGuildIds.contains(event.guild.id)) {
        return;
      }

      _currentGuildIds.add(event.guild.id);
      plugin._onGuildJoinController.add(event);
    });

    client.onGuildDelete.listen((event) {
      if (event.isUnavailable) {
        return;
      }

      _currentGuildIds.remove(event.guild.id);
      plugin._onGuildLeaveController.add(event);
    });
  }
}
