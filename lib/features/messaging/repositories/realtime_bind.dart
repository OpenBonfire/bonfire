// import 'package:bonfire/features/channels/controllers/channel.dart';
// import 'package:bonfire/features/messaging/repositories/messages.dart';
// import 'package:bonfire/features/messaging/repositories/realtime_messages.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'realtime_bind.g.dart';

// @riverpod
// class RealtimeBind extends _$RealtimeBind {
//   @override
//   Future<void> build() async {
//     var channelId = ref.watch(channelControllerProvider);
//     var realtimeProvider = ref.watch(realtimeMessagesProvider);

//     realtimeProvider.whenData((value) {
//       // ref
//       //     .read(messagesProvider.notifier)
//       //     .processRealtimeMessages(value, channelId);
//     });
//   }
// }
