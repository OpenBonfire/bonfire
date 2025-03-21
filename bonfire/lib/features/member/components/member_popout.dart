import 'package:bonfire/features/member/repositories/user_profile.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPopoutCard extends ConsumerStatefulWidget {
  final Snowflake userId;
  const UserPopoutCard(this.userId, {super.key});

  @override
  ConsumerState<UserPopoutCard> createState() => _UserPopoutCardState();
}

class _UserPopoutCardState extends ConsumerState<UserPopoutCard> {
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileControllerProvider(widget.userId));
    final theme = Theme.of(context).custom;

    profile.when(
      data: (data) {
        print("Got data");
        print(data?.user);
      },
      error: (error, stack) {
        print("Got error");
        print(error);
        print(stack);
      },
      loading: () {
        print("Loading");
      },
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorTheme.foreground,
        borderRadius: BorderRadius.circular(20),
      ),
      width: 500,
      height: 400,
    );
  }
}
