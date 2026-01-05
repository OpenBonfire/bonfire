import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
// import 'package:bonfire/features/user/controllers/presence.dart';
import 'package:bonfire/shared/models/pair.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'channel_members.g.dart';

@Riverpod(keepAlive: true)
class GuildMemberList extends _$GuildMemberList {
  Pair<List<GuildMemberListGroup>, List<dynamic>>? _data;

  @override
  Future<Pair<List<GuildMemberListGroup>, List<dynamic>>> build(
    Snowflake guildId,
  ) async {
    return _data ?? Pair([], []);
  }

  void setData(
    Snowflake channelId,
    Pair<List<GuildMemberListGroup>, List<dynamic>> newData,
  ) {
    _data = newData;
    state = AsyncValue.data(_data!);
  }

  void applyOperations(List<MemberListUpdateOperation> operations) {
    final currentData = _data ?? Pair([], []);
    List<GuildMemberListGroup> newGroups = List.from(currentData.first);
    List<dynamic> newMemberList = List.from(currentData.second);

    for (final operation in operations) {
      if (operation is MemberListUpdateSyncOperation) {
        final range = operation.range;
        final items = operation.items;

        if (range.length == 2) {
          final start = range[0];
          final end = range[1];

          // Ensure the range is valid
          if (start >= 0 && end >= start && start <= newMemberList.length) {
            // Clamp the end index to the length of the list
            final endIndex = end.clamp(0, newMemberList.length);

            // Ensure the replacement list is not empty
            if (items.isNotEmpty) {
              // Calculate the length of the range to be replaced
              final rangeLength = endIndex - start;

              // If the replacement list is smaller than the range, pad it with null or empty values
              // Note: items is List<GuildMemberListUpdateItem>, we might need to cast or convert
              List<dynamic> data = List.from(items);

              if (data.length < rangeLength) {
                final padding = List<dynamic>.filled(
                  rangeLength - data.length,
                  null,
                );
                data = [...data, ...padding];
              }

              // Replace the range
              newMemberList.replaceRange(start, endIndex, data);
            } else {
              // If the replacement list is empty, remove the range
              newMemberList.removeRange(start, endIndex);
            }
          } else {
            // If the range is invalid, append the data to the list
            newMemberList.addAll(items);
          }
        }
      } else if (operation is MemberListUpdateInsertOperation) {
        final index = operation.index;
        final item = operation.item;
        // errors a lot
        // return;
        // newMemberList.insert(index, item);
      } else if (operation is MemberListUpdateDeleteOperation) {
        final index = operation.index;
        if (index < newMemberList.length) {
          newMemberList.removeAt(index);
        }
      } else if (operation is MemberListUpdateUpdateOperation) {
        final index = operation.index;
        final item = operation.item;
        if (index < newMemberList.length) {
          newMemberList[index] = item;
        }
      } else if (operation is MemberListUpdateInvalidateOperation) {
        // TODO: Handle invalidation if needed
      }
    }

    _data = Pair(newGroups, newMemberList);
    state = AsyncValue.data(_data!);
  }
}

@Riverpod(keepAlive: true)
class ChannelMembers extends _$ChannelMembers {
  FirebridgeGateway? client;
  Snowflake guildId = Snowflake.zero;
  Snowflake channelId = Snowflake.zero;
  Map<Snowflake, List<List<int>>> currentSubscriptions = {};

  @override
  Future<Pair<List<GuildMemberListGroup>, List<dynamic>>?> build() async {
    client = ref.watch(clientControllerProvider);
    if (client != null) {
      _updateSubscriptions();
    }
    return null;
  }

  void setRoute(Snowflake guildId, Snowflake channelId) async {
    this.guildId = guildId;
    this.channelId = channelId;
    currentSubscriptions = {
      channelId: [
        [0, 99],
      ],
    };
    _updateSubscriptions();
  }

  void loadMemberRange(int lowerBound, int upperBound) {
    if (!currentSubscriptions.containsKey(channelId)) {
      currentSubscriptions[channelId] = [];
    }

    final ranges = currentSubscriptions[channelId]!;
    final exists = ranges.any(
      (range) => range[0] == lowerBound && range[1] == upperBound,
    );

    if (!exists) {
      ranges.add([lowerBound, upperBound]);
      // Ensure [0, 99] is always present if needed, or just add the new range.
      // The original code cleared and added [0, 99] and the new range.
      // Let's replicate that behavior if it makes sense, or just append.
      // Original:
      // subscription.memberRange.clear();
      // subscription.memberRange.add(... 0, 99 ...);
      // subscription.memberRange.add(... lower, upper ...);

      // It seems it wants to keep 0-99 and the new range.
      // But wait, if I just add, the list grows.
      // The original code cleared it first.

      // Let's stick to the original logic:
      currentSubscriptions[channelId] = [
        [0, 99],
        [lowerBound, upperBound],
      ];

      _updateSubscriptions();
    }
  }

  void _updateSubscriptions() {
    if (client != null) {
      if (guildId == Snowflake.zero) {
        return; // when in dms I don't think sending op 37 is required
      }
      client!.updateGuildSubscriptionsBulk(
        GuildSubscriptionsBulkBuilder(
          subscriptions: {
            guildId: GuildSubscription(
              typing: true,
              memberUpdates: true,
              channels: currentSubscriptions,
            ),
          },
        ),
      );
    }
  }

  void updateMemberList(
    List<MemberListUpdateOperation> operations,
    Snowflake guildId,
    List<dynamic> groups,
  ) {
    final currentState = ref.read(guildMemberListProvider(guildId)).value;
    if (currentState != null) {
      final newGroups = groups.cast<GuildMemberListGroup>();

      ref
          .read(guildMemberListProvider(guildId).notifier)
          .applyOperations(operations);

      final updatedMemberList =
          ref.read(guildMemberListProvider(guildId)).value?.second ?? [];

      for (final itemList in updatedMemberList) {
        for (final item in itemList) {
          if (item is Member) {
            // I think this is a sign that firebridge itself should user notifiers (probably riverpod)
            // If we used riverpod to cache this data and such, we could make it reactive, and probably disable
            // event requirements all together.
            // Maybe keeping the api wrapper simple is key? It just seems like there's always 2 layers of logic.
            // if (item.initialPresence != null) {
            //   ref
            //       .read(presenceControllerProvider(item.user!.id).notifier)
            //       .setPresence(item.initialPresence!);
            // }
          }
        }
      }

      final newPair = Pair(newGroups, updatedMemberList);

      ref
          .read(guildMemberListProvider(guildId).notifier)
          .setData(guildId, newPair);
    }
  }
}
