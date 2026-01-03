import 'package:bonfire/features/channels/components/category.dart';
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
    // TODO: We need a ChannelButton that can take ids
    final channels =
        (ref.watch(guildChannelsProvider(guildId))?.cast<GuildChannel>() ?? [])
            .toList();

    channels.sort((a, b) {
      return a.position - b.position;
    });

    final Map<Snowflake, List<GuildChannel>> categoryMap = {};
    for (GuildChannel channel in channels) {
      if (channel.parentId != null) {
        if (!categoryMap.containsKey(channel.parentId!)) {
          categoryMap[channel.parentId!] = [];
        }
        categoryMap[channel.parentId!]!.add(channel);
      }
    }

    List<Widget> slivers = [];

    for (GuildChannel channel in channels) {
      if (channel.parentId == null && channel is! GuildCategory) {
        slivers.add(
          SliverToBoxAdapter(
            child: ChannelButton(
              name: channel.name,
              icon: Icon(Icons.numbers_rounded),
              selected: false,
              onPressed: () {
                HapticFeedback.lightImpact();
              },
            ),
          ),
        );
      }
    }

    for (GuildChannel channel in channels) {
      if (channel is GuildCategory) {
        final categoryChannels = categoryMap[channel.id];
        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.only(top: 8.0),
            sliver: ChannelCategorySliver(
              name: channel.name,
              channels:
                  categoryChannels
                      ?.map(
                        (e) => ChannelButton(
                          name: e.name,
                          icon: Icon(Icons.numbers_rounded),
                          selected: false,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                          },
                        ),
                      )
                      .toList() ??
                  [],
            ),
          ),
        );
      }
    }

    return CustomScrollView(slivers: slivers);
  }
}
