import 'dart:collection';
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
  bool get wantKeepAlive => true;

  nyxx.UserGuild? guild;
  String serverName = "Loading";
  String memberCount = "0";
  List<nyxx.GuildChannel> channels = [];
  Map<String, int> channelCache = {};

  final DefaultCacheManager cacheManager = DefaultCacheManager();

  Future<List<nyxx.GuildChannel>> _fetchChannels() async {
    List<nyxx.GuildChannel> fetchedChannels = await guild!.fetchChannels();

    Map<String, int> channelData = {};
    for (var channel in fetchedChannels) {
      channelData[channel.name] = channel.id.value;
    }

    await cacheManager.putFile(
      "file://${guild!.id}channels",
      utf8.encode(json.encode(channelData)),
    );

    return fetchedChannels;
  }

  Future<Map<String, int>> _fetchChannelsFromCache() async {
    if (guild == null) return {};

    FileInfo? file =
        await cacheManager.getFileFromCache("file://${guild!.id}channels");

    if (file == null) return {};

    var channelData = json.decode(utf8.decode(file!.file.readAsBytesSync()))
        as Map<String, dynamic>;

    Map<String, int> typedChannelCache = {};
    channelData.forEach((key, value) {
      typedChannelCache[key] = value as int;
    });

    return typedChannelCache;
  }

  @override
  void initState() {
    super.initState();
    guildSignal.subscribe((guild) {
      if (guild != null) {
        setState(() {
          this.guild = guild;
        });
      }
    });

    channelSignal.subscribe((channel) {
      globalChannel = channel;
    });
  }

  Widget _buildChannelList(Object channels) {
    print("-- runtime info -- ");
    print(channels.runtimeType);
    return Container(
      decoration: const BoxDecoration(color: backgroundColor),
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
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
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
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
                child: (channels.runtimeType ==
                        UnmodifiableListView<nyxx.GuildChannel>)
                    ? ListView.builder(
                        itemCount: (channels as List<nyxx.GuildChannel>).length,
                        itemBuilder: (context, index) {
                          return ChannelButton(channel: channels[index]);
                        },
                      )
                    : ListView.builder(
                        itemCount: channelCache.length,
                        itemBuilder: (context, index) {
                          print("BUILDING FROM MAP!");
                          print(channelCache.keys.elementAt(index));
                          return ChannelButton(
                            cachedChannelName:
                                channelCache.keys.elementAt(index),
                            cachedChannelId:
                                channelCache.values.elementAt(index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("builded channel list");

    if (guild == null) {
      return _buildChannelList([]);
    }

    AsyncValue<List<nyxx.GuildChannel>> channels =
        ref.watch(channelsProvider(globalClient!, guild!));

    return FutureBuilder(
      future: channels.when(
        loading: () => _fetchChannelsFromCache(),
        error: (error, st) => Future.error('Error: $error'),
        data: (channels) => _fetchChannels(),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // print("Waiting for cache...asd");
          return FutureBuilder(
              future: _fetchChannelsFromCache(),
              builder: (context, snapshot2) {
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return _buildChannelList([]);
                } else if (snapshot2.hasError) {
                  return Center(child: Text('Error: ${snapshot2.error}'));
                } else {
                  print("Cache returned, going to build list");
                  return _buildChannelList(snapshot2.data as Map<String, int>);
                }
              });
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          if (snapshot.data.runtimeType !=
              UnmodifiableListView<nyxx.GuildChannel>) {
            return _buildChannelList(snapshot.data as Map<String, int>);
          }
          // print("Fetch from network returned!");
          return _buildChannelList(snapshot.data as List<nyxx.GuildChannel>);
        }
      },
    );
  }
}

class ChannelButton extends StatefulWidget {
  final nyxx.GuildChannel? channel;
  final String? cachedChannelName;
  final int? cachedChannelId;

  const ChannelButton(
      {super.key, this.channel, this.cachedChannelName, this.cachedChannelId});

  @override
  State<ChannelButton> createState() => _ChannelButtonState();
}

class _ChannelButtonState extends State<ChannelButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.channel == null) {
      print("Rebuilding from cache");
    } else {
      // print("Rebuilding from network");
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 30, top: 2),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: foreground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: OutlinedButton(
            style: ButtonStyle(
              alignment: Alignment.centerLeft,
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.transparent,
              ),
              side: MaterialStateProperty.all<BorderSide>(
                const BorderSide(
                  width: 0.5,
                  color: Color.fromARGB(255, 77, 77, 77),
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
              if (widget.channel != null) {
                channelSignal.set(widget.channel);
              } else {
                print("Tried to change page before channel was loaded.");
              }
              // channelSignal.set(channel);
            },
            child: SizedBox(
              height: 25,
              child: Text(
                (widget.channel != null)
                    ? widget.channel!.name
                    : widget.cachedChannelName!,
                textAlign: TextAlign.left,
                style: GoogleFonts.inriaSans(
                  color: const Color.fromARGB(189, 255, 255, 255),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
