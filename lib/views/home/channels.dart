import 'package:bonfire/colors.dart';
import 'package:bonfire/globals.dart';
import 'package:bonfire/providers/discord/guilds.dart';
import 'package:bonfire/style.dart';
import 'package:bonfire/views/home/signal/channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyxx/nyxx.dart' as nyxx;

class ChannelList extends ConsumerStatefulWidget {
  nyxx.UserGuild? guild;
  String serverName = "Loading";
  String memberCount = "0";
  List<nyxx.GuildChannel> channels = [];
  // channel cache map that contains snowflake as the key, channels at the value
  Map<String, List<nyxx.GuildChannel>> channelCache = {};

  ChannelList({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChannelListState();
}

class _ChannelListState extends ConsumerState<ChannelList> {
  Widget _channelButton(String name) {
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
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
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
                    return primaryColor; // Change this to the desired splash color
                  }
                  return Colors.transparent; // No splash color by default
                },
              ),
            ),
            onPressed: () {},
            child: Container(
              height: 25,
              child: Text(
                name,
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

  @override
  void initState() {
    super.initState();
    guildSignal.subscribe((guild) {
      if (guild != null) {
        setState(() {
          widget.guild = guild;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.guild != null) {
      var detailedGuild =
          ref.watch(guildProvider(globalClient!, widget.guild!.id)).valueOrNull;

      if (detailedGuild != null) {
        widget.serverName = detailedGuild.name;
        widget.memberCount = detailedGuild.approximateMemberCount.toString();

        var channelList = ref
            .watch(channelsProvider(globalClient!, detailedGuild))
            .valueOrNull;

        if (channelList != null) {
          print(channelList.length);
          widget.channels = channelList;
          widget.channelCache[widget.guild!.id.value.toString()] = channelList;
        }
      }
    }

    if (widget.guild != null) {
      ;
      widget.channels =
          widget.channelCache[widget.guild!.id.value.toString()] ??
              widget.channels;
    }

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
                          (widget.guild != null)
                              ? widget.guild!.name
                              : "Loading",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${widget.memberCount} members",
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
                  itemCount: widget.channels.length,
                  itemBuilder: (context, index) {
                    widget.channels[index];
                    return _channelButton(widget.channels[index].name);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
