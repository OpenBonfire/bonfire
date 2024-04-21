import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/features/overview/widgets/icon.dart';
import 'package:bonfire/shared/models/guild.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({super.key});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  Widget iconBuilder(Guild guild) {
    if (guild.icon != null) {
      return guild.icon!;
    } else {
      return Text(guild.name[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    var guildWatch = ref.watch(guildsProvider);
    List<Guild> guildList = [];
    guildWatch.when(
        data: (guilds) {
          guildList = guilds;
        },
        error: (data, trace) {},
        loading: () {});

    return SizedBox(
      width: 60,
      height: double.infinity,
      child: Center(
        child: SizedBox(
            width: 50,
            child: ListView.builder(
              itemCount: guildList.length,
              itemBuilder: (context, index) {
                return iconBuilder(guildList[index]);
              },
            )),
      ),
    );
  }
}
