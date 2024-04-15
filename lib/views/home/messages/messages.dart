import 'package:bonfire/colors.dart';
import 'package:bonfire/style.dart';
import 'package:bonfire/views/home/signal/channel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyxx/nyxx.dart';

class Messages extends StatefulWidget {
  Messages({Key? key});

  GuildChannel? channel;

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    // Move your subscription logic here
    channelSignal.subscribe((channel) {
      if (channel != null) {
        setState(() {
          widget.channel = channel;
        });
        if (channel.type == ChannelType.guildText) {
          var _channel = channel as GuildTextChannel;
          _channel.messages.fetchMany(limit: 100).then((value) {
            setState(() {
              messages = value;
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _textScrollView(),
        const MessageBar(),
      ],
    );
  }

  Widget _textScrollView() {
    return Expanded(
      child: Container(
        // color: Colors.white,
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            children: messages
                .map((message) => MessageBox(message: message))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class MessageBar extends StatelessWidget {
  const MessageBar({Key? key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      decoration: const BoxDecoration(
        color: foreground,
        border:
            Border.symmetric(horizontal: BorderSide(color: foregroundBright)),
      ),
      child: TextField(
        style: GoogleFonts.inriaSans(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Message',
          hintStyle: GoogleFonts.inriaSans(color: Colors.white),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class MessageBox extends StatelessWidget {
  final Message message;

  const MessageBox({Key? key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0XffC9C9C9),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, top: 12),
                child: Text(
                  message.author.username,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.inriaSans(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6, top: 2),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 94,
                  child: Text(
                    message.content,
                    softWrap: true,
                    style: GoogleFonts.inriaSans(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
