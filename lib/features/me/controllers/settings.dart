import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

@Riverpod(keepAlive: true)
class PrivateMessageHistory extends _$PrivateMessageHistory {
  AuthUser? user;

  @override
  List<PrivateChannel> build() {
    return [];
  }

  void setMessageHistory(List<PrivateChannel> channels) {
    state = channels;
  }
}

@Riverpod(keepAlive: true)
class GuildFolders extends _$GuildFolders {
  AuthUser? user;

  @override
  List<GuildFolder>? build() {
    return null;
  }

  void setGuildFolders(List<GuildFolder> folders) {
    state = folders;
  }
}

@Riverpod(keepAlive: true)
class ChannelReadState extends _$ChannelReadState {
  AuthUser? user;

  @override
  Map<Snowflake, ReadState>? build() {
    return null;
  }

  void setReadStates(List<ReadState> readStates) async {
    state = readStates
        .asMap()
        .map((key, value) => MapEntry(value.partialChannel.id, value));
  }
}
