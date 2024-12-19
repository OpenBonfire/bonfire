import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/utils/formatters.dart';

/// Extensions on [PartialUser].
extension PartialUserExtensions on PartialUser {
  /// Fetch all the mutual guilds the client shares with this user.
  ///
  /// Returns a mapping of the guilds the client and this user share mapped to this user's member in each guild.
  ///
  /// This method only operates on guilds in the client's cache.
  Future<Map<Guild, Member>> fetchMutualGuilds() async {
    final result = <Guild, Member>{};

    for (final guild in List.of(manager.client.guilds.cache.values)) {
      try {
        result[guild] = await guild.members[id].get();
      } on HttpResponseError {
        // Member was not found in the guild
      }
    }

    return result;
  }

  /// A URL clients can visit to open the user's profile.
  Uri get url => Uri.https(manager.client.apiOptions.host, '/users/$id');

  /// A mention of this user.
  String get mention => userMention(id);
}
