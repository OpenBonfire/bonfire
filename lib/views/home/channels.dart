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
      "${guild!.id}channels",
      utf8.encode(json.encode(channelData)),
    );

    return fetchedChannels;
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

        if (snapshot.connectionState == ConnectionState.waiting) {
          _fetchChannelsFromCache().then((value) {});
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
                      itemCount: (channels.isEmpty)
                          ? channelCache.length
                          : channels.length,
                      itemBuilder: (context, index) {
                        return _channelButton(channels[index]);
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

  /*
  todo: allow `channel` to work with either a guild channnel or the cache

  You should probably make it a class anyways since you need to change it's
  state (like sidebar button)
  */

  Widget _channelButton(nyxx.GuildChannel channel) {
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
              channelSignal.set(channel);
            },
            child: Container(
              height: 25,
              child: Text(
                channel.name,
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
