// import 'package:bonfire/features/authenticator/repositories/auth.dart';
// import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
// import 'package:firebridge/firebridge.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'channel_repo.g.dart';

// /// Fetches the current channel from the [channelid].
// @Riverpod(keepAlive: true)
// class ChannelRepository extends _$ChannelRepository {
//   Channel? channel;

//   @override
//   Future<Channel?> build(Snowflake channelId) async {
//     if (channelId == Snowflake.zero) {
//       return null;
//     }

//     var auth = ref.watch(authProvider.notifier).getAuth();

//     if (auth is! AuthUser) {
//       return null;
//     }

//     return await auth.client.channels.get(channelId);
//   }
// }
