import 'dart:convert';

import 'package:bonfire/features/authenticator/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

/*
I'm not a huge fan of this- it should really be in seperate controllers per-feature.
Most (if not all) of these will be modified via gateway events, and all the ready
event does it provide an initial state, so this isn't really proper convention.

tldr: We need to make seperate controllers for each feature within the feature folder.
I am already doing that with friends.
*/

final DefaultCacheManager _cacheManager = DefaultCacheManager();

@Riverpod(keepAlive: true)
class PrivateMessageHistory extends _$PrivateMessageHistory {
  AuthUser? user;

  @override
  List<Channel> build() {
    return [];
  }

  void setMessageHistory(List<Channel> channels) {
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

  // TODO: When a message is recieved, we need to create a new read state for that channel
  // when a message is acked, we need to also modify the read state
  // read states are never updated, you have to re-"calculate" them

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
  var cacheKey = "guilds";

  @override
  FutureOr<List<Guild>?> build() async {
    var cacheData = await _cacheManager.getFileFromCache(cacheKey);

    if (cacheData != null) {
      var decoded = json.decode(utf8.decode(cacheData.file.readAsBytesSync()));
      var mapped = (decoded.map((e) => user!.client.guilds.parse(e)).toList());
      return List<Guild>.from(mapped);
    }
    return null;
  }

  void setGuilds(List<Guild> guilds) {
    state = AsyncValue.data(guilds);
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
