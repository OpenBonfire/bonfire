import 'dart:convert';

import 'package:bonfire/colors.dart';
import 'package:bonfire/globals.dart';
import 'package:bonfire/style.dart';
import 'package:bonfire/views/home/signal/channel.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyxx/nyxx.dart' as nyxx;

class CachedChannel {
  final int id;
  final String name;

  CachedChannel({required this.id, required this.name});

  factory CachedChannel.fromJson(Map<String, dynamic> json) {
    return CachedChannel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

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
  List<CachedChannel> channels = [];
  Map<int, List<CachedChannel>> channelCache = {};

  final DefaultCacheManager cacheManager = DefaultCacheManager();

  Future<List<CachedChannel>> _fetchChannels() async {
    int? guildId = guild?.id.value;
    if (guildId == null) return [];

    FileInfo? cachedFileInfo =
        await cacheManager.getFileFromCache("channel_list_$guildId");
    List<CachedChannel>? cachedChannels;

    // Load cached data if available
    if (cachedFileInfo != null &&
        !cachedFileInfo.validTill.isBefore(DateTime.now())) {
      String jsonString = await cachedFileInfo.file.readAsString();
      List<dynamic> cachedData = json.decode(jsonString);
      cachedChannels =
          cachedData.map((data) => CachedChannel.fromJson(data)).toList();
    }

    // Fetch fresh data from the server
    List<nyxx.GuildChannel> fetchedChannels = await guild!.fetchChannels();
    List<CachedChannel> freshChannels = fetchedChannels
        .map((channel) =>
            CachedChannel(id: channel.id.value, name: channel.name))
        .toList();

    // Update cache with fresh data
    List<Map<String, dynamic>> channelDataList =
        freshChannels.map((freshChannel) => freshChannel.toJson()).toList();
    String jsonString = json.encode(channelDataList);
    await cacheManager.putFile(
        "channel_list_$guildId", utf8.encode(jsonString));

    // If fresh data is available, update the widget
    if (freshChannels.isNotEmpty) {
      setState(() {
        channels = freshChannels;
      });
      print("sending fresh");
      return freshChannels;
    }
    // If no fresh data, return cached data
    else if (cachedChannels != null) {
      print("sending cached");
      return cachedChannels;
    }
    // If no data available, return empty list
    else {
      return [];
    }
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

    return FutureBuilder<List<CachedChannel>>(
      future: _fetchChannels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (channels.isNotEmpty) {
            return _buildChannelList(channels);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          channels = snapshot.data ?? [];
          return _buildChannelList(channels);
        }
      },
    );
  }

  Widget _buildChannelList(List<CachedChannel> channels) {
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
                child: ListView.builder(
                  itemCount: channels.length,
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
  }

  Widget _channelButton(CachedChannel channel) {
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
            onPressed: () {},
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
