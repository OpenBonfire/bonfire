import 'dart:typed_data';

import 'package:bonfire/features/member/repositories/avatar.dart';
import 'package:firebridge/firebridge.dart' hide Builder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Avatar extends ConsumerWidget {
  final double? width;
  final double? height;
  final MessageAuthor author;
  final Snowflake guildId;
  final Snowflake channelId;
  const Avatar(
      {super.key,
      required this.author,
      required this.guildId,
      required this.channelId,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var avatar = ref.watch(messageAuthorAvatarProvider(author));

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: width ?? 45,
        height: height ?? 45,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: avatar.when(
              data: (data) {
                return _buildAvatarImage(data);
              },
              loading: () {
                return const SizedBox();
              },
              error: (error, stack) {
                return const Icon(Icons.error);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(Uint8List? data) {
    return AnimatedOpacity(
      opacity: data != null ? 1.0 : 0.0,
      duration: const Duration(seconds: 1),
      child: data != null ? Image.memory(data) : Container(),
    );
  }
}
