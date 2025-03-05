import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/shared/models/pair.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'channel_members.g.dart';

@Riverpod(keepAlive: true)
class GuildMemberList extends _$GuildMemberList {
  Pair<List<GuildMemberListGroup>, List<dynamic>>? _data;

  @override
  Future<Pair<List<GuildMemberListGroup>, List<dynamic>>> build(
      Snowflake guildId) async {
    return _data ?? Pair([], []);
  }

  void setData(
    Snowflake channelId,
    Pair<List<GuildMemberListGroup>, List<dynamic>> newData,
  ) {
    _data = newData;
    state = AsyncValue.data(_data!);
  }

  void applyOperations(List<Map<String, dynamic>> operations) {
    final currentData = _data ?? Pair([], []);
    List<GuildMemberListGroup> newGroups = List.from(currentData.first);
    List<dynamic> newMemberList = List.from(currentData.second);

    for (final operation in operations) {
      print("Range: ${operation['range']}");
      final type = operation['type'] as MemberListUpdateType;
      var data = operation['data'];
      final range = operation['range'] as List<dynamic>;
      final index = operation['index'] as int?;
      print("doing switch case stuff for $type");
      switch (type) {
        case MemberListUpdateType.sync:
          if (range != null) {
            final start = range[0];
            final end = range[1];

            // Ensure the range is valid
            if (start >= 0 && end >= start && start <= newMemberList.length) {
              // Clamp the end index to the length of the list
              final endIndex = end.clamp(0, newMemberList.length);

              // Ensure the replacement list is not empty
              if (data is List<dynamic> && data.isNotEmpty) {
                // Calculate the length of the range to be replaced
                final rangeLength = endIndex - start;

                // If the replacement list is smaller than the range, pad it with null or empty values
                if (data.length < rangeLength) {
                  final padding =
                      List<dynamic>.filled(rangeLength - data.length, null);
                  data = [...data, ...padding];
                }

                // Replace the range
                newMemberList.replaceRange(
                  start,
                  endIndex,
                  data,
                );
              } else {
                // If the replacement list is empty, remove the range
                newMemberList.removeRange(start, endIndex);
              }
            } else {
              // If the range is invalid, append the data to the list
              newMemberList.addAll(data as List<dynamic>);
            }
          }
          break;
        case MemberListUpdateType.insert:
          if (index != null) {
            newMemberList.insert(index, data);
          }
          break;
        case MemberListUpdateType.delete:
          if (index != null && index < newMemberList.length) {
            newMemberList.removeAt(index);
          }
          break;
        case MemberListUpdateType.update:
          if (index != null && index < newMemberList.length) {
            newMemberList[index] = data;
          }
          break;
        case MemberListUpdateType.invalidate:
          print("no idea on what to do here");
          print(operation['data']);
          break;
        case MemberListUpdateType.unknown:
          break;
      }
    }

    _data = Pair(newGroups, newMemberList);
    state = AsyncValue.data(_data!);
  }
}

@Riverpod(keepAlive: true)
class ChannelMembers extends _$ChannelMembers {
  AuthUser? user;
  Snowflake guildId = Snowflake.zero;
  Snowflake channelId = Snowflake.zero;
  List<GuildSubscriptionChannel> currentSubscriptions = [];

  @override
  Future<Pair<List<GuildMemberListGroup>, List<dynamic>>?> build() async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    if (authOutput is AuthUser) {
      user = authOutput;
    }

    return null;
  }

  void setRoute(Snowflake guildId, Snowflake channelId) async {
    this.guildId = guildId;
    this.channelId = channelId;
    currentSubscriptions = [
      GuildSubscriptionChannel(
        channelId: channelId,
        memberRange: [
          GuildMemberRange(
            lowerMemberBound: 0,
            upperMemberBound: 99,
          )
        ],
      )
    ];
    _updateSubscriptions();
  }

  void loadMemberRange(int lowerBound, int upperBound) {
    final exists = currentSubscriptions.any((sub) => sub.memberRange.any(
        (range) =>
            range.lowerMemberBound == lowerBound &&
            range.upperMemberBound == upperBound));

    if (!exists) {
      final subscription = currentSubscriptions.firstWhere(
        (sub) => sub.channelId == channelId,
        orElse: () => GuildSubscriptionChannel(
          channelId: channelId,
          memberRange: [],
        ),
      );

      subscription.memberRange.add(GuildMemberRange(
        lowerMemberBound: lowerBound,
        upperMemberBound: upperBound,
      ));

      if (subscription.memberRange.length > 3) {
        subscription.memberRange.removeAt(0);
      }

      if (!currentSubscriptions.contains(subscription)) {
        currentSubscriptions.add(subscription);
      }

      _updateSubscriptions();
    }
  }

  void _updateSubscriptions() {
    if (user is AuthUser) {
      user!.client.updateGuildSubscriptionsBulk(GuildSubscriptionsBulkBuilder()
        ..subscriptions = [
          GuildSubscription(
            typing: true,
            memberUpdates: true,
            channels: currentSubscriptions,
            guildId: guildId,
          )
        ]);
    }
  }

  void updateMemberList(GuildMemberListUpdateEvent event) {
    final currentState =
        ref.read(guildMemberListProvider(event.guildId)).valueOrNull;
    if (currentState != null) {
      final newGroups = event.groups.cast<GuildMemberListGroup>();

      ref.read(guildMemberListProvider(event.guildId).notifier).applyOperations(
            event.memberList!.cast<Map<String, dynamic>>(),
          );

      final updatedMemberList = ref
              .read(guildMemberListProvider(event.guildId))
              .valueOrNull
              ?.second ??
          [];
      final newPair = Pair(newGroups, updatedMemberList);

      ref.read(guildMemberListProvider(event.guildId).notifier).setData(
            event.guildId,
            newPair,
          );
    }
  }
}
