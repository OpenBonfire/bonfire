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
  Sidebar({Key? key}) : super(key: key);

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  @override
  void initState() {
    super.initState();
  }

Future<List<Widget>> _generateCards(List<UserGuild> guilds) async {
  List<Widget> cards = [];

  // Create a list of futures for fetching icon images
  List<Future<Image>> iconFutures = [];
  for (var guild in guilds) {
    iconFutures.add(_fetchIconImage(guild.icon));
  }

  // Wait for all icon images to be fetched
  List<Image> icons = await Future.wait(iconFutures);

  // Create cards with fetched icon images
  for (int i = 0; i < guilds.length; i++) {
    var icon = icons[i];
    cards.add(Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          // decoration: BoxDecoration(
          //   color: foregroundBright,
          //   borderRadius: BorderRadius.circular(10),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withOpacity(0.1),
          //       spreadRadius: 1,
          //       blurRadius: 5,
          //       offset: const Offset(0, 2),
          //     ),
          //   ],
          // ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: icon),
        ),
      ),
    ));
  }

  return cards;
}

Future<Image> _fetchIconImage(CdnAsset? icon) async {
  if (icon != null) {
    var bytes = await icon.fetch();
    return Image.memory(bytes);
  }
  // If icon is null, return an empty image
  return Image.asset('assets/placeholder.png'); // Adjust the placeholder image path as per your project
}


  @override
  Widget build(BuildContext context) {
    AsyncValue<List<UserGuild>> guilds =
        ref.watch(guildsProvider(globalClient!));

    return Container(
      width: 75,
      height: double.infinity,
      decoration:
          BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
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
