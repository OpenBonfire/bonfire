import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/channels/components/category.dart';
import 'package:bonfire/features/channels/components/channel_button.dart';
import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:bonfire/features/guilds/components/header.dart';
import 'package:bonfire/features/media/components/image.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GuildChannelList extends ConsumerWidget {
  final Snowflake guildId;
  const GuildChannelList({super.key, required this.guildId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChannel = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.pathParameters["channelId"];

    final guild = ref.watch(guildProvider(guildId))!;
    final client = ref.watch(clientControllerProvider);

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

    List<Widget> channelSlivers = [];

    for (GuildChannel channel in channels) {
      if (channel.parentId == null && channel is! GuildCategory) {
        channelSlivers.add(
          SliverToBoxAdapter(
            child: ChannelButton(
              name: channel.name,
              icon: Icon(Icons.numbers_rounded),
              selected: channel.id.toString() == selectedChannel,
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go("/channels/$guildId/${channel.id}");
              },
            ),
          ),
        );
      }
    }

    for (GuildChannel channel in channels) {
      if (channel is GuildCategory) {
        final categoryChannels = categoryMap[channel.id];
        channelSlivers.add(
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
                          selected: e.id.toString() == selectedChannel,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.go("/channels/$guildId/${e.id}");
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

    return CustomScrollView(
      slivers: [
        if (guild.banner != null)
          SliverToBoxAdapter(
            child: DiscordNetworkImage(
              // todo: better way of handling the size parameter
              "${guild.banner!.getUrl(client!).toString()}?size=512",
              fit: .cover,
              borderRadius: .only(
                topLeft: .circular(24),
                topRight: .circular(8),
              ),
            ),
          ),
        SliverPersistentHeader(
          delegate: SectionHeaderDelegate(guildId),
          pinned: true,
        ),

        ...channelSlivers,
      ],
    );
  }
}

class SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Snowflake guildId;

  SectionHeaderDelegate(this.guildId);

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).primaryColor,
      alignment: Alignment.centerLeft,
      child: GuildOverview(guildId: guildId),
    );
  }

  @override
  double get maxExtent => 55;

  @override
  double get minExtent => 52;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
