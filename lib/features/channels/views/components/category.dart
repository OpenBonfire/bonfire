import 'package:bonfire/features/channels/views/components/button.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Category extends StatefulWidget {
  final GuildChannel category;
  final Snowflake guildId;
  final Snowflake channelId;
  final List<GuildChannel> children;

  const Category(
      {super.key,
      required this.category,
      required this.guildId,
      required this.channelId,
      required this.children});

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
              child: Text(widget.category.name.toUpperCase(),
                  style: GoogleFonts.publicSans(
                    color: const Color.fromARGB(189, 255, 255, 255),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  )),
            ),
          ),
          SizedBox(
            child: Column(
              children: widget.children
                  .map((channel) => ChannelButton(
                        currentGuildId: widget.guildId,
                        currentChannelId: widget.channelId,
                        channel: channel,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
