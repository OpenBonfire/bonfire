import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/guild/controllers/current_guild.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/shared/models/member.dart';
import 'package:bonfire/shared/models/message.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guild_members.g.dart';

@riverpod
class GuildMembers extends _$GuildMembers {
  AuthUser? user;

  @override
  Future<List<BonfireGuildMember>> build() async {
    final currentGuild = ref.watch(currentGuildControllerProvider);
    var authOutput = ref.watch(authProvider.notifier).getAuth();

    if (currentGuild != null) {
      final guildId = currentGuild.id;
      // todo: add caching for this
      fetchMembers(authOutput, guildId);
    }

    return [];
  }

  Future<void> fetchMembers(
    authOutput,
    int guildId, {
    int? before,
    int? count,
    bool? lock = true,
    bool? requestAvatar = true,
  }) async {
    if (authOutput != null && authOutput is AuthUser) {
      user = authOutput;

      print("FETCHING MEMBERS!");
      var guildSnowflake = Snowflake(guildId);
      print("getting client...");
      print(user);
      var client = user!.client;
      // print("getting guilds...");
      // var guilds = client.guilds;
      // print("getting guild...");
      // var guild = await guilds.get(guildSnowflake);
      print("getting members...");
      var members = user!.client.gateway.listGuildMembers(
        guildSnowflake
      );

      print("MEMBERS!");
      members.listen((member) {
        print("-- STREAM --");
        print(member);
      });

      

      // print("MEMBERS!");
      // print(members);
      // List<BonfireGuildMember> bonfireMembers = members.map((member) {
      //   return BonfireGuildMember(
      //     id: member.id.value,
      //     guildId: guildId,
      //     displayName: member.user!.username,
      //     name: member.user!.username,
      //     iconUrl: member.user!.avatar.url.toString(),
      //   );
      // }).toList();
      // state = AsyncData(bonfireMembers);
    }
  }
}
