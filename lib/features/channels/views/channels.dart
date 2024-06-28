import 'package:bonfire/features/channels/repositories/channels.dart';
import 'package:bonfire/features/channels/views/components/button.dart';
import 'package:bonfire/features/channels/views/components/category.dart';
import 'package:bonfire/features/guild/repositories/guild.dart';
import 'package:bonfire/features/guild/views/guild_overview.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart' hide Builder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_headers/sticky_headers.dart';

class ChannelsList extends ConsumerStatefulWidget {
  final Guild guild;
  final Channel channel;
  const ChannelsList({super.key, required this.guild, required this.channel});

  @override
  ConsumerState<ChannelsList> createState() => _ChannelsListState();
}

class _ChannelsListState extends ConsumerState<ChannelsList> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).padding.top;
    var channelWatch = ref.watch(channelsProvider(widget.guild));

    var channels = channelWatch.valueOrNull ?? [];
    var guildBannerUrl =
        ref.watch(guildBannerUrlProvider(widget.guild)).valueOrNull;

    if (scrollController.hasClients) scrollController.jumpTo(0.0);

    var channelsWithoutParent = channels
        .where((channel) =>
            ((channel as GuildChannel).parent == null) &&
            (channel.type != ChannelType.guildCategory))
        .toList();

    Map<GuildChannel, List<GuildChannel>> categoryMap = {};

    // group channels by category
    channels.forEach((channel) {
      if (channel.type == ChannelType.guildCategory) {
        categoryMap[channel as GuildChannel] = [];
      }
    });

    channels.forEach((channel) {
      if (channel.type != ChannelType.guildCategory) {
        var parentChannel = (channel as GuildChannel).parent;

        if (parentChannel != null && categoryMap[parentChannel] != null) {
          // print(categoryMap[parentChannel]);
          categoryMap[parentChannel]!.add(channel);
        }
      }
    });

    Widget buildChannelButton(int index) {
      if (index < channelsWithoutParent.length) {
        var _channel = channelsWithoutParent[index];
        return ChannelButton(
            currentChannel: widget.channel as GuildChannel,
            currentGuild: widget.guild,
            channel: _channel as GuildChannel);
      } else {
        var categoryIndex = index - channelsWithoutParent.length;
        var category = categoryMap.keys.elementAt(categoryIndex);
        var children = categoryMap[category] ?? [];
        if (category != null) {
          return Category(
              guild: widget.guild,
              channel: widget.channel,
              category: category,
              children: children);
        } else {
          return Container();
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(top: topPadding, right: 30),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).custom.colorTheme.channelListBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Builder(builder: (context) {
            var colItems = <Widget>[];
            for (var i = 0;
                i < channelsWithoutParent.length + categoryMap.length;
                i++) {
              colItems.add(buildChannelButton(i));
            }
            return ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(8),
              ),
              child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    (guildBannerUrl != null)
                        ? Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .custom
                                  .colorTheme
                                  .foreground,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(12)),
                            ),
                            child: Image.network(
                              "$guildBannerUrl?size=512",
                              fit: BoxFit.cover,
                            ))
                        : Container(),
                    StickyHeader(
                      header: GuildOverview(guild: widget.guild),
                      content: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: colItems,
                        ),
                      ),
                    ),
                  ]),
            );
          }),
        ),
      ),
    );
  }
}
