import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForumCard extends ConsumerStatefulWidget {
  final Snowflake? postId;
  const ForumCard({
    super.key,
    this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForumCardState();
}

class _ForumCardState extends ConsumerState<ForumCard> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
