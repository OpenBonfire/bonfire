import 'package:bonfire/features/guild/repositories/guild.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebridge/firebridge.dart';
import 'package:go_router/go_router.dart';

/// Sidebar with icons for each guild
class Sidebar extends ConsumerStatefulWidget {
  final Snowflake guildId;
  const Sidebar({super.key, required this.guildId});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  UserGuild? previousSelectedGuild;

  @override
  Widget build(BuildContext context) {
    var guildWatch = ref.watch(guildsProvider);

    List<UserGuild> guildList = [];
    guildWatch.when(
        data: (guilds) {
          guildList = guilds;
        },
        error: (data, trace) {},
        loading: () {});

    return Column(
      children: [
        Expanded(
          child: SizedBox(
            width: 60,
            height: double.infinity,
            child: Center(
              child: SizedBox(
                  width: 60,
                  child: ListView.builder(
                    itemCount: guildList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          SidebarIcon(
                            selected: widget.guildId == guildList[index].id,
                            guild: guildList[index],
                          ),
                          const SizedBox(
                            height: 8,
                          )
                        ],
                      );
                    },
                  )),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).padding.bottom + 50,
        )
      ],
    );
  }
}

/// Icon for each guild in the sidebar
class SidebarIcon extends ConsumerStatefulWidget {
  final bool selected;
  final UserGuild guild;

  const SidebarIcon({super.key, required this.selected, required this.guild});

  @override
  ConsumerState<SidebarIcon> createState() => _SidebarIconState();
}

class _SidebarIconState extends ConsumerState<SidebarIcon> {
  Future<double> get iconHeight => Future<double>.value(40);

  Widget iconBuilder(UserGuild guild, Image? guildIcon) {
    if (guildIcon != null) {
      // return Image.network(guild.icon!.url.toString(),
      //     width: 45, height: 45, fit: BoxFit.cover);
      return guildIcon;
    } else {
      String iconText = "";
      List<String> words = guild.name.split(" ");
      for (var word in words) {
        if (word.isEmpty) continue;
        iconText += word[0];
      }

      return SizedBox(
          width: 50,
          height: 45,
          child: Container(
            color: Theme.of(context).custom.colorTheme.foreground,
            child: Center(
                child: Text(iconText,
                    overflow: TextOverflow.ellipsis,
                    style:
                        CustomTextTheme().titleSmall.copyWith(fontSize: 12))),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Image? guildIcon =
        ref.watch(guildIconProvider(widget.guild.id)).valueOrNull;
    return SizedBox(
      width: 60,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Center(
            child: SizedBox(
              width: 45,
              height: 45,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      onPressed: () {
                        widget.guild.manager
                            .get(widget.guild.id)
                            .then((Guild guild) async {
                          GoRouter.of(context).go(
                              '/channels/${widget.guild.id}/${guild.rulesChannelId ?? (await guild.fetchChannels()).first.id.value}');
                        });
                      },
                      child: ClipRRect(
                        // TODO: Animate border radius change
                        borderRadius: BorderRadius.all(
                            Radius.circular(widget.selected ? 15 : 100)),
                        child: iconBuilder(widget.guild, guildIcon),
                      ))),
            ),
          ),
          if (widget.selected)
            Positioned(
              left: 0,
              child: FutureBuilder<double>(
                future: iconHeight,
                builder: (context, snapshot) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOutExpo,
                    width: 4,
                    height: snapshot.data ?? 8,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                          topRight: Radius.circular(8),
                        )),
                  );
                },
              ),
            )
        ],
      ),
    );
  }
}
