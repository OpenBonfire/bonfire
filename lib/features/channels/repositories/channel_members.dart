// import 'package:bonfire/features/authentication/repositories/auth.dart';
// import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
// import 'package:bonfire/features/user/controllers/presence.dart';
// import 'package:bonfire/shared/models/pair.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:firebridge/firebridge.dart';

// part 'channel_members.g.dart';

// @Riverpod(keepAlive: true)
// class GuildMemberList extends _$GuildMemberList {
//   Pair<List<GuildMemberListGroup>, List<dynamic>>? _data;

//   @override
//   Future<Pair<List<GuildMemberListGroup>, List<dynamic>>> build(
//     Snowflake guildId,
//   ) async {
//     return _data ?? Pair([], []);
//   }

//   void setData(
//     Snowflake channelId,
//     Pair<List<GuildMemberListGroup>, List<dynamic>> newData,
//   ) {
//     _data = newData;
//     state = AsyncValue.data(_data!);
//   }

//   void applyOperations(List<MemberListUpdateOperation> operations) {
//     final currentData = _data ?? Pair([], []);
//     List<GuildMemberListGroup> newGroups = List.from(currentData.first);
//     List<dynamic> newMemberList = List.from(currentData.second);

//     for (final operation in operations) {
//       final type = operation.type;
//       var data = operation.data;
//       final range = operation.range;
//       final index = operation.index;

//       switch (type) {
//         case MemberListUpdateType.sync:
//           if (range != null && range.length == 2) {
//             final start = range[0];
//             final end = range[1];

//             // Ensure the range is valid
//             if (start >= 0 && end >= start && start <= newMemberList.length) {
//               // Clamp the end index to the length of the list
//               final endIndex = end.clamp(0, newMemberList.length);

//               // Ensure the replacement list is not empty
//               if (data is List<dynamic> && data.isNotEmpty) {
//                 // Calculate the length of the range to be replaced
//                 final rangeLength = endIndex - start;

//                 // If the replacement list is smaller than the range, pad it with null or empty values
//                 if (data.length < rangeLength) {
//                   final padding = List<dynamic>.filled(
//                     rangeLength - data.length,
//                     null,
//                   );
//                   data = [...data, ...padding];
//                 }

//                 // Replace the range
//                 newMemberList.replaceRange(start, endIndex, data);
//               } else {
//                 // If the replacement list is empty, remove the range
//                 newMemberList.removeRange(start, endIndex);
//               }
//             } else {
//               // If the range is invalid, append the data to the list
//               newMemberList.addAll(data as List<dynamic>);
//             }
//           }
//           break;
//         case MemberListUpdateType.insert:
//           if (index != null) {
//             // errors a lot
//             return;
//             // newMemberList.insert(index, data);
//           }
//           break;
//         case MemberListUpdateType.delete:
//           if (index != null && index < newMemberList.length) {
//             newMemberList.removeAt(index);
//           }
//           break;
//         case MemberListUpdateType.update:
//           if (index != null && index < newMemberList.length) {
//             newMemberList[index] = data;
//           }
//           break;
//         case MemberListUpdateType.invalidate:
//           // TODO: Handle invalidation if needed
//           break;
//         case MemberListUpdateType.unknown:
//           break;
//       }
//     }

//     _data = Pair(newGroups, newMemberList);
//     state = AsyncValue.data(_data!);
//   }
// }

// @Riverpod(keepAlive: true)
// class ChannelMembers extends _$ChannelMembers {
//   AuthUser? user;
//   Snowflake guildId = Snowflake.zero;
//   Snowflake channelId = Snowflake.zero;
//   List<GuildSubscriptionChannel> currentSubscriptions = [];

//   @override
//   Future<Pair<List<GuildMemberListGroup>, List<dynamic>>?> build() async {
//     var authOutput = ref.watch(clientControllerProvider);
//     if (authOutput is AuthUser) {
//       user = authOutput;
//     }

//     return null;
//   }

//   void setRoute(Snowflake guildId, Snowflake channelId) async {
//     this.guildId = guildId;
//     this.channelId = channelId;
//     currentSubscriptions = [
//       GuildSubscriptionChannel(
//         channelId: channelId,
//         memberRange: [
//           GuildMemberRange(lowerMemberBound: 0, upperMemberBound: 99),
//         ],
//       ),
//     ];
//     _updateSubscriptions();
//   }

//   void loadMemberRange(int lowerBound, int upperBound) {
//     final exists = currentSubscriptions.any(
//       (sub) => sub.memberRange.any(
//         (range) =>
//             range.lowerMemberBound == lowerBound &&
//             range.upperMemberBound == upperBound,
//       ),
//     );

//     if (!exists) {
//       final subscription = currentSubscriptions.firstWhere(
//         (sub) => sub.channelId == channelId,
//         orElse: () =>
//             GuildSubscriptionChannel(channelId: channelId, memberRange: []),
//       );

//       subscription.memberRange.clear();
//       subscription.memberRange.add(
//         GuildMemberRange(lowerMemberBound: 0, upperMemberBound: 99),
//       );
//       subscription.memberRange.add(
//         GuildMemberRange(
//           lowerMemberBound: lowerBound,
//           upperMemberBound: upperBound,
//         ),
//       );

//       _updateSubscriptions();
//     }
//   }

//   void _updateSubscriptions() {
//     if (user is AuthUser) {
//       if (guildId == Snowflake.zero) {
//         return; // when in dms I don't think sending op 37 is required
//       }
//       user!.client.updateGuildSubscriptionsBulk(
//         GuildSubscriptionsBulkBuilder()
//           ..subscriptions = [
//             GuildSubscription(
//               typing: true,
//               memberUpdates: true,
//               channels: currentSubscriptions,
//               guildId: guildId,
//             ),
//           ],
//       );
//     }
//   }

//   void updateMemberList(
//     List<MemberListUpdateOperation> operations,
//     Snowflake guildId,
//     List<dynamic> groups,
//   ) {
//     final currentState = ref.read(guildMemberListProvider(guildId)).value;
//     if (currentState != null) {
//       final newGroups = groups.cast<GuildMemberListGroup>();

//       ref
//           .read(guildMemberListProvider(guildId).notifier)
//           .applyOperations(operations);

//       final updatedMemberList =
//           ref.read(guildMemberListProvider(guildId)).value?.second ?? [];

//       for (final itemList in updatedMemberList) {
//         for (final item in itemList) {
//           if (item is Member) {
//             // I think this is a sign that firebridge itself should user notifiers (probably riverpod)
//             // If we used riverpod to cache this data and such, we could make it reactive, and probably disable
//             // event requirements all together.
//             // Maybe keeping the api wrapper simple is key? It just seems like there's always 2 layers of logic.
//             if (item.initialPresence != null) {
//               ref
//                   .read(presenceControllerProvider(item.user!.id).notifier)
//                   .setPresence(item.initialPresence!);
//             }
//           }
//         }
//       }

//       final newPair = Pair(newGroups, updatedMemberList);

//       ref
//           .read(guildMemberListProvider(guildId).notifier)
//           .setData(guildId, newPair);
//     }
//   }
// }
