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
  ReadState? build(Snowflake channelId) {
    return null;
  }

  void setReadState(ReadState readState) async {
    state = readState;
  }
}

@Riverpod(keepAlive: true)
class SelfStatusState extends _$SelfStatusState {
  AuthUser? user;

  @override
  UserStatus? build() {
    return null;
  }

  void setSelfStatus(UserStatus userStatus) {
    state = userStatus;
  }
}

@Riverpod(keepAlive: true)
class UserStatusState extends _$UserStatusState {
  AuthUser? user;

  @override
  UserStatus? build(Snowflake userId) {
    return null;
  }

  void setUserStatus(UserStatus userStatus) {
    state = userStatus;
  }
}

@Riverpod(keepAlive: true)
class UserActivityState extends _$UserActivityState {
  AuthUser? user;

  @override
  List<Activity>? build(Snowflake userId) {
    return null;
  }

  void setUserActivity(List<Activity> activities) {
    state = activities;
  }
}

@Riverpod(keepAlive: true)
class CustomStatusState extends _$CustomStatusState {
  AuthUser? user;

  @override
  CustomStatus? build() {
    return null;
  }

  void setCustomStatus(CustomStatus userStatus) {
    state = userStatus;
  }
}

@Riverpod(keepAlive: true)
class GuildsState extends _$GuildsState {
  AuthUser? user;

  @override
  List<Guild>? build() {
    return null;
  }

  void setGuilds(List<Guild> guilds) {
    if (guilds.isEmpty) {
      print("Guilds are empty, ignoring state update!!!");
      return;
    }
    state = guilds;
  }
}

// @Riverpod(keepAlive: true)
// class VoiceStates extends _$VoiceStates {
//   @override
//   List<MapEntry<Snowflake, VoiceState>>? build(Snowflake guildId) {
//     return null;
//   }

//   void setVoiceStates(List<MapEntry<Snowflake, VoiceState>> voiceStates) {
//     state = voiceStates;
//   }
// }
