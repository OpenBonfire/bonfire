import 'package:bonfire/features/channels/components/channel_button.dart';
import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuildChannelList extends ConsumerWidget {
  final Snowflake guildId;
  const GuildChannelList({super.key, required this.guildId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guild = ref.watch(guildProvider(guildId))!;
    final channels = ref.watch(guildChannelsProvider(guildId)) ?? [];

    // print("channels = $channels");
    return CustomScrollView(
      slivers: [
        SliverList.separated(
          itemCount: channels.length,
          itemBuilder: (context, index) {
            final channel = channels[index] as GuildChannel;
            return ChannelButton(
              name: channel.name,
              icon: Icon(Icons.numbers_rounded),
              selected: false,
              onPressed: () {
                HapticFeedback.lightImpact();
              },
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 4),
        ),
      ],
    );
  }
}
