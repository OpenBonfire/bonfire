import 'package:bonfire/features/member/components/member_popout.dart';
import 'package:bonfire/features/member/repositories/avatar.dart';
import 'package:bonfire/shared/components/drawer/mobile_drawer.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:firebridge/firebridge.dart' hide Builder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return InkWell(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(100),
      onTap: () {
        HapticFeedback.mediumImpact();
        if (shouldUseDesktopLayout(context)) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                  child: UserPopoutCard(
                    author.id,
                    guildId: guildId,
                  ),
                );
              });
        } else {
          // open drawer
          GlobalDrawer.of(context)!.setChild(
            UserPopoutCard(
              author.id,
              guildId: guildId,
            ),
          );

          GlobalDrawer.of(context)!.toggleDrawer();
        }
      },
      child: SizedBox(
        width: width ?? 40,
        height: height ?? 40,
        child: ClipOval(
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
