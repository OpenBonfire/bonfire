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

    // TODO: Just handle this in the provider that also calculates permissions
    final channels =
        (ref.watch(guildChannelsProvider(guildId))?.cast<GuildChannel>() ?? [])
            .toList();

    channels.sort((a, b) {
      return a.position - b.position;
    });

    final categories = channels.whereType<GuildCategory>();
    final Map<Snowflake, Snowflake> categoryMap = {};
    for (GuildChannel channel in channels) {
      if (channel.parentId != null) {
        categoryMap[channel.id] = channel.parentId!;
      }
    }

    // print("channels = $channels");
    return CustomScrollView(
      slivers: [
        // SliverList.separated(
        //   itemCount: channels.length,
        //   itemBuilder: (context, index) {
        //     final channel = channels[index];
        //     if (channel is GuildCategory) {
        //       return
        //     }
        //   },
        //   separatorBuilder: (context, index) => SizedBox(height: 4),
        // ),
      ],
    );
  }
}
