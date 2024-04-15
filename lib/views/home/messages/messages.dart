import 'package:bonfire/views/home/signal/channel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyxx/nyxx.dart';

class Messages extends StatefulWidget {
  Messages({super.key});

  GuildChannel? channel;
  List<Message> messages = [];

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
          _channel.messages.fetchMany(limit: 100).then((value) {
            setState(() {
              widget.messages = value;
            });
          });
        }
      }
    });
  }

  Widget _buildMessage(Message message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        // width: 100,
        // height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                // child: Text(message.author.username),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0XffC9C9C9),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 12),
                  child: Text(message.author.username,
                      style: GoogleFonts.inriaSans(
                        color: Colors.white,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 2),
                  child: Text(message.content,
                  softWrap: true,
                      style: GoogleFonts.inriaSans(
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _textScrollView() {
    return ListView.builder(
      itemCount: widget.messages.length,
      reverse: true,
      itemBuilder: (context, index) {
        return _buildMessage(widget.messages[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _textScrollView();
  }
}
