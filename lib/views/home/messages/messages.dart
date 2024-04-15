import 'package:bonfire/views/home/signal/channel.dart';
import 'package:flutter/material.dart';
import 'package:nyxx/nyxx.dart';

class Messages extends StatefulWidget {
  Messages({super.key});

  GuildChannel? channel;

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  void initState() {
    super.initState();
    channelSignal.subscribe((channel) {
      if (channel != null) {
        print('Channel: ${channel.name}');
        print(channel.type);
        setState(() {
          widget.channel = channel;
        });
        if (channel.type == ChannelType.guildText) {
          var _channel = channel as GuildTextChannel;
          print(_channel.messages.fetchMany(limit: 4));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(widget.channel?.name ?? 'No channel selected'));
  }
}
