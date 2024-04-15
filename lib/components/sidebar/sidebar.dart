import 'dart:io';

import 'package:bonfire/colors.dart';
import 'package:bonfire/globals.dart';
import 'package:bonfire/providers/discord/guilds.dart';
import 'package:bonfire/views/home/signal/channel.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/components/sidebar/icon.dart';
import 'package:bonfire/style.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyxx/nyxx.dart';
import 'package:signals/signals.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

    List<Future<ImageProvider>> iconFutures = [];
    for (var guild in guilds) {
      iconFutures.add(fetchIconImage(guild.icon));
    }

    List<ImageProvider> icons = await Future.wait(iconFutures);

    for (int i = 0; i < guilds.length; i++) {
      ImageProvider icon = icons[i];
      UserGuild guild = guilds[i];
      cards.add(IconButton(guild: guild, icon: Image(image: icon)));
    }

    return cards;
  }

  Future<ImageProvider> fetchIconImage(CdnAsset? icon) async {
    if (icon != null) {
      FileInfo? fromCache =
          await DefaultCacheManager().getFileFromCache(icon.hash);

      if (fromCache != null) {
        return MemoryImage(fromCache.file.readAsBytesSync());
      }

      var bytes = await icon.fetch();
      String cacheKey = icon.hash;
      File fileData = await _saveToCache(bytes, cacheKey);
      return MemoryImage(fileData.readAsBytesSync());
    }

    return const AssetImage('assets/placeholder.png');
  }

  Future<File> _saveToCache(List<int> bytes, String cacheKey) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/$cacheKey';

    await File(path).writeAsBytes(bytes);

    return File(path);
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

class IconButton extends StatefulWidget {
  UserGuild guild;
  Image icon;

  IconButton({super.key, required this.guild, required this.icon});

  bool selected = false;

  @override
  State<IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<IconButton> {
  @override
  void initState() {
    super.initState();
    guildSignal.subscribe((UserGuild? updatedGuild) {
      if (guild != null) {
        setState(() {
          if (updatedGuild == null) {
            widget.selected = false;
            return;
          }
          if (updatedGuild!.id == widget.guild.id) {
            widget.selected = true;
          } else {
            widget.selected = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          if (widget.selected)
            Positioned(
              left: 0,
              child: Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: title,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: TextButton(
                onPressed: () {
                  guildSignal.set(widget.guild);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // Set padding to zero
                  minimumSize: const Size(0, 0), // Ensure minimum size is zero
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: widget.icon),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
