import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';

class ChannelsList extends StatefulWidget {
  const ChannelsList({super.key});

  @override
  State<ChannelsList> createState() => _ChannelsListState();
}

class _ChannelsListState extends State<ChannelsList> {
  Widget _channelButton(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 30),
      child: SizedBox(
        width: double.infinity,
        height: 35,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            foregroundColor: Theme.of(context).custom.colorTheme.textColor1,
            backgroundColor: Theme.of(context).custom.colorTheme.cardSelected,
          ),
          onPressed: () {},
          child: SizedBox(
            height: 35,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(name,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).custom.textTheme.bodyText2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.foreground),
        child: ListView(
          padding: const EdgeInsets.only(top: 12),
          children: [
            _channelButton("bruh"),
            _channelButton("bruh"),
          ],
        ),
      ),
    );
  }
}
