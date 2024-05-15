import 'package:bonfire/features/guild/controllers/current_guild.dart';
import 'package:bonfire/features/members/repositories/guild_members.dart';
import 'package:bonfire/theme/theme.dart';
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
            children: [topBox(), Expanded(child: MemberScrollView())],
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

    // TODO: Handle if current guild is null
    var memberListProvider =
        ref.watch(guildMembersProvider); //.fetchMembers(currentGuild!.id);
    var memberList = memberListProvider.valueOrNull ?? [];

    // print("LOADED MEMBERS!");
    // print(memberList);

    return Center(
      child: ListView.builder(
          itemCount: memberList.length,
          itemBuilder: (context, index) {
            return Text("Member $index");
          }),
    );
  }
}
