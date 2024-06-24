import 'package:bonfire/features/guild/controllers/current_guild.dart';
import 'package:bonfire/features/channels/repositories/channel_members.dart';
import 'package:bonfire/features/members/views/components/member_card.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// List of members in the selected guild (not implemented)
class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  Widget topBox() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
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
            children: [topBox(), const Expanded(child: MemberScrollView())],
          )),
    );
  }
}

class MemberScrollView extends ConsumerStatefulWidget {
  const MemberScrollView({super.key});

  @override
  ConsumerState<MemberScrollView> createState() => MemberScrollViewState();
}

class MemberScrollViewState extends ConsumerState<MemberScrollView> {
  @override
  Widget build(BuildContext context) {
    var currentGuild = ref.watch(currentGuildControllerProvider);

    var memberList = ref.watch(channelMembersProvider).valueOrNull ?? [];

    return SizedBox(
      child: ListView.builder(
        itemCount: memberList.length,
        itemBuilder: (context, index) {
          if (memberList[index].toString().contains("Member(")) {
            var members = memberList[index] as List;
            return Column(
              children: members.map<Widget>((member) {
                member = member as Member;
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 32, right: 12, bottom: 8),
                  child: MemberCard(member: member),
                );
              }).toList(),
            );
          }
          return Container(); // Return an empty container if the check fails
        },
      ),
    );
  }
}
