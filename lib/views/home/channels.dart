import 'dart:convert';

import 'package:bonfire/colors.dart';
import 'package:bonfire/globals.dart';
import 'package:bonfire/providers/discord/guilds.dart';
import 'package:bonfire/style.dart';
import 'package:bonfire/views/home/signal/channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // Import Flutter Cache Manager
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyxx/nyxx.dart' as nyxx;

class ChannelList extends ConsumerStatefulWidget {
  const ChannelList({Key? key}) : super(key: key);

  @override
  _ChannelListState createState() => _ChannelListState();
}

class _ChannelListState extends ConsumerState<ChannelList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

  nyxx.UserGuild? guild;
  String serverName = "Loading";
  String memberCount = "0";
  List<nyxx.GuildChannel> channels = [];
  Map<nyxx.GuildCategory, List<nyxx.GuildChannel>> categories = {};
  Map<String, List<nyxx.GuildChannel>> channelCache = {};

  final DefaultCacheManager cacheManager = DefaultCacheManager();

  _updateMemberCount() async {
    ref.read(guildProvider(globalClient!, guild!.id)).maybeWhen(orElse: () {
      print("Guild not found");
    }, data: (guild) {
      print(this.guild!.approximateMemberCount);
    });
  }

  Future<List<nyxx.GuildChannel>> _fetchChannels() async {
    List<nyxx.GuildChannel> fetchedChannels = await guild!.fetchChannels();

    List<nyxx.GuildChannel> channels = [];
    for (var channel in fetchedChannels) {
      if (channel.type != nyxx.ChannelType.guildCategory) {
        channels.add(channel);
      } else {
        if (categories[channel as nyxx.GuildCategory] == null) {
          categories[channel] = [];
        }

        categories[channel]!.addAll(
          fetchedChannels.where((c) => c.parentId == channel.id),
        );
      }
    }

    Map<String, int> channelData = {};
    for (var channel in channels) {
      channelData[channel.name] = channel.id.value;
    }

    await cacheManager.putFile(
      "${guild!.id}channels",
      utf8.encode(json.encode(channelData)),
    );

    return channels;
  }

  Future<Map<String, int>> _fetchChannelsFromCache() async {
    Map<String, int> channelData =
        json.decode((await cacheManager.getSingleFile(
      "${guild!.id}channels",
    ))
            .readAsBytesSync()
            .toString());

    return channelData;
  }

  @override
  void initState() {
    super.initState();
    guildSignal.subscribe((guild) {
      if (guild != null) {
        setState(() {
          this.guild = guild;
          categories = {};
        });
      }
    });

    channelSignal.subscribe((channel) {
      globalChannel = channel;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: _fetchChannels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            channels = snapshot.data as List<nyxx.GuildChannel>;
          }
        }
        return Container(
          decoration: const BoxDecoration(color: backgroundColor),
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
            child: Container(
              decoration: const BoxDecoration(
                color: foreground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guild != null ? guild!.name : "Loading",
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "$memberCount members",
                                textAlign: TextAlign.left,
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return Category(
                          category: categories.keys.elementAt(index),
                          children: categories.values.elementAt(index),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Category extends StatefulWidget {
  final nyxx.GuildCategory category;
  final List<nyxx.GuildChannel> children;

  const Category({super.key, required this.category, required this.children});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: SizedBox(
              height: 25,
              child: Text(widget.category.name,
                  style: GoogleFonts.inriaSans(
                    color: const Color.fromARGB(189, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ),
          SizedBox(
            child: Column(
              children: widget.children
                  .map((channel) => ChannelButton(channel: channel))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ChannelButton extends StatefulWidget {
  final nyxx.GuildChannel channel;
  const ChannelButton({super.key, required this.channel});

  @override
  State<ChannelButton> createState() => ChannelButtonState();
}

class ChannelButtonState extends State<ChannelButton> {
  bool selected = false;
  Widget prefix = const Text("X");

  @override
  void initState() {
    super.initState();
    channelSignal.subscribe((channel) {
      if (channel != null) {
        setState(() {
          if (channel.id.value == widget.channel.id.value) {
            selected = true;
          } else {
            selected = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 30, top: 0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: foreground,
            borderRadius: BorderRadius.circular(5),
          ),
          child: OutlinedButton(
            style: ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              ),
              elevation: MaterialStateProperty.all<double>(0),
              
              alignment: Alignment.centerLeft,
              backgroundColor: MaterialStateProperty.all<Color>(
                selected? const Color.fromARGB(45, 0, 0, 0): Colors.transparent,
              ),
              side: MaterialStateProperty.all<BorderSide>(
                BorderSide(
                  width: 0.5,
                  color: selected
                      ? const Color.fromARGB(255, 77, 77, 77)
                      : Color.fromARGB(0, 77, 77, 77)
                ),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              overlayColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return primaryColor;
                  }
                  return Colors.transparent;
                },
              ),
            ),

            onPressed: () {
              setState(() {
                selected = true;
              });
              channelSignal.set(widget.channel);
            },

            child: SizedBox(
              height: 20,
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  "# ${widget.channel.name}",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.inriaSans(
                    color: const Color.fromARGB(189, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}