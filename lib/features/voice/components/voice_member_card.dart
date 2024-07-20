import 'dart:typed_data';

import 'package:bonfire/features/user/card/repositories/user.dart';
import 'package:bonfire/features/user/card/repositories/user_icon.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VoiceMemberCard extends ConsumerStatefulWidget {
  final Snowflake userId;
  final Snowflake guildId;
  final Snowflake channelId;
  const VoiceMemberCard({
    super.key,
    required this.userId,
    required this.guildId,
    required this.channelId,
  });

  @override
  ConsumerState<VoiceMemberCard> createState() => _VoiceMemberCardState();
}

class _VoiceMemberCardState extends ConsumerState<VoiceMemberCard> {
  @override
  Widget build(BuildContext context) {
    User? user = ref.watch(getUserFromIdProvider(widget.userId)).valueOrNull;
    Uint8List? icon = ref.watch(userIconProvider(widget.userId)).value;

    return SizedBox(
      height: 35,
      child: Padding(
        padding: const EdgeInsets.only(left: 32.0, right: 10.0),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            side: const BorderSide(
              color: Colors.transparent,
              width: 0.1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            foregroundColor:
                Theme.of(context).custom.colorTheme.deselectedChannelText,
            backgroundColor: Colors.transparent,
          ),
          onPressed: () {},
          child: SizedBox(
            height: 35,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: user != null
                    ? Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: icon != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(36),
                                    child: Image.memory(
                                      icon,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Row(
                            children: [
                              Text(
                                // todo: I need to get the member for nickname
                                user.globalName ?? user.username,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .custom
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        color: Theme.of(context)
                                            .custom
                                            .colorTheme
                                            .deselectedChannelText),
                              ),
                              const Spacer(),
                            ],
                          )),
                        ],
                      )
                    : const SizedBox(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
