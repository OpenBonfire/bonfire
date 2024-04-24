import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  Widget topBox() {
    return Container(
      width: double.infinity,
      height: 270,
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.foreground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
            left: 40, top: MediaQuery.of(context).padding.top + 20),
        child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Text(
                  "Channel Name / Icon",
                  style: Theme.of(context).custom.textTheme.titleMedium,
                ),
                Text(
                  "Channel Description",
                  style: Theme.of(context).custom.textTheme.subtitle2,
                ),
              ],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
          padding: const EdgeInsets.only(left: 0), // 40
          child: Column(
            children: [topBox()],
          )),
    );
  }
}

class MemberScrollView extends StatefulWidget {
  const MemberScrollView({super.key});

  @override
  State<MemberScrollView> createState() => MemberScrollViewState();
}

class MemberScrollViewState extends State<MemberScrollView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
