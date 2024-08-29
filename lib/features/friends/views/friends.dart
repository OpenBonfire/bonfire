import 'package:bonfire/features/friends/views/friend_card.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsList extends ConsumerStatefulWidget {
  final Snowflake channelId;
  const FriendsList({super.key, required this.channelId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FriendsListState();
}

class _FriendsListState extends ConsumerState<FriendsList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return FriendCard(
              channelId: Snowflake.zero,
            );
          },
        ),
      ),
    );
  }
}
