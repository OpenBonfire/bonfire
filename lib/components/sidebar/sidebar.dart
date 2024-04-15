import 'package:bonfire/colors.dart';
import 'package:bonfire/globals.dart';
import 'package:bonfire/providers/discord/guilds.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/components/sidebar/icon.dart';
import 'package:bonfire/style.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyxx/nyxx.dart';

class Sidebar extends ConsumerStatefulWidget {
  ValueChanged<UserGuild>? onGuildSelected;
  
  Sidebar({Key? key}) : super(key: key);

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  @override
  void initState() {
    super.initState();
  }

  Widget _iconButton(UserGuild guild, Image icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero, // Set padding to zero
              minimumSize: const Size(0, 0), // Ensure minimum size is zero
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100), child: icon),
          ),
        ),
      ),
    );
  }

  Future<List<Widget>> _generateCards(List<UserGuild> guilds) async {
    List<Widget> cards = [];

    List<Future<Image>> iconFutures = [];
    for (var guild in guilds) {
      iconFutures.add(_fetchIconImage(guild.icon));
    }

    List<Image> icons = await Future.wait(iconFutures);

    for (int i = 0; i < guilds.length; i++) {
      Image icon = icons[i];
      UserGuild guild = guilds[i];
      cards.add(_iconButton(guild, icon));
    }

    return cards;
  }

  Future<Image> _fetchIconImage(CdnAsset? icon) async {
    if (icon != null) {
      var bytes = await icon.fetch();
      return Image.memory(bytes);
    }
    // If icon is null, return an empty image
    return Image.asset(
        'assets/placeholder.png'); // Adjust the placeholder image path as per your project
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<UserGuild>> guilds =
        ref.watch(guildsProvider(globalClient!));

    return Container(
      width: 75,
      height: double.infinity,
      decoration: const BoxDecoration(color: backgroundColor),
      child: FutureBuilder<List<Widget>>(
        future: guilds.when(
          loading: () => Future.value([]),
          error: (error, st) => Future.error('Error: $error'),
          data: (guilds) => _generateCards(guilds),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView(children: snapshot.data ?? []);
          }
        },
      ),
    );
  }
}
