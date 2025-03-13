import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/user/components/user_avatar.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DmIcon extends ConsumerStatefulWidget {
  final Snowflake privateChannelId;
  const DmIcon({
    super.key,
    required this.privateChannelId,
  });

  @override
  ConsumerState<DmIcon> createState() => _DmIconState();
}

class _DmIconState extends ConsumerState<DmIcon> {
  @override
  Widget build(BuildContext context) {
    // IDEA: We could include the presence of the user here, unlike Discord which doesn't provide that
    Channel? channel =
        ref.watch(channelControllerProvider(widget.privateChannelId));
    if (channel == null) {
      return const SizedBox();
    }

    List<User>? recipients;
    if (channel is DmChannel) {
      recipients = (channel).recipients;
    } else if (widget is GroupDmChannel) {
      recipients = (channel as GroupDmChannel).recipients;
    } else {
      print("VERY BAD! Recipients is null");
    }

    User user = recipients!.firstOrNull!;

    return UserAvatar(
      user: user,
    );
  }
}
