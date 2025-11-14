import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/extensions/managers/guild_manager.dart';

/// Extensions on [PartialGuild]s.
extension PartialGuildExtensions on PartialGuild {
  /// A URL clients can visit to navigate to this guild.
  Uri get url => Uri.https(manager.client.apiOptions.host, '/guilds/$id');

  /// Same as [listBans], but has no limit on the number of bans returned.
  ///
  /// {@macro paginated_endpoint_streaming_parameters}
  Stream<Ban> streamBans(
          {Snowflake? after, Snowflake? before, int? pageSize}) =>
      manager.streamBans(id, after: after, before: before, pageSize: pageSize);

  /// Return a list of channels in the client's cache that are in this guild.
  List<GuildChannel> get cachedChannels => manager.client.channels.cache.values
      .whereType<GuildChannel>()
      .where((element) => element.guildId == id)
      .toList();
}

/// Extensions on [Guild]s.
extension GuildExtensions on Guild {
  /// The acronym of the guild if no icon is chosen.
  String get acronym {
    return name
        .replaceAll(r"'s ", ' ')
        .replaceAllMapped(RegExp(r'\w+'), (match) => match[0]![0])
        .replaceAll(RegExp(r'\s'), '');
  }
}
