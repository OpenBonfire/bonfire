import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guilds.g.dart';

/// Fetches the current guild from [guildid].
@Riverpod(keepAlive: true)
class GuildsController extends _$GuildsController {
  List<Guild>? guilds;

  @override
  List<Guild>? build() {
    return null;
  }

  void setGuilds(List<Guild> guild) {
    state = guild;
  }
}
