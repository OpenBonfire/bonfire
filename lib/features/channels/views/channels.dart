import 'package:bonfire/features/channels/repositories/channels.dart';
import 'package:bonfire/features/channels/components/button.dart';
import 'package:bonfire/features/channels/components/category.dart';
import 'package:bonfire/features/guild/repositories/guild.dart';
import 'package:bonfire/features/guild/views/guild_overview.dart';
import 'package:bonfire/features/user/card/views/card_desktop.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart' hide Builder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:universal_platform/universal_platform.dart';

class ChannelsList extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  const ChannelsList({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  @override
  ConsumerState<ChannelsList> createState() => _ChannelsListState();
}

class _ChannelsListState extends ConsumerState<ChannelsList> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var topPadding =
        (MediaQuery.paddingOf(context).top) +
        (UniversalPlatform.isDesktopOrWeb ? 8 : 0);

    var channelWatch = ref.watch(channelsProvider(widget.guildId));
    var channels = channelWatch.value ?? [];

    List<Channel> channelsWithoutParent = [];
    Map<GuildChannel, List<GuildChannel>> categoryMap = {};

    for (var channel in channels) {
      if (channel.type == ChannelType.guildCategory) {
        categoryMap[channel as GuildChannel] = [];
      }
    }

    for (var channel in channels) {
      if (channel.type != ChannelType.guildCategory) {
        var guildChannel = channel as GuildChannel;
        var parentChannel = guildChannel.parent;

        if (parentChannel == null) {
          channelsWithoutParent.add(channel);
        } else if (categoryMap[parentChannel] != null) {
          categoryMap[parentChannel]!.add(guildChannel);
        }
      }
    }

    var guildBannerUrl = ref
        .watch(guildBannerUrlProvider(widget.guildId))
        .value;

    return Padding(
      padding: EdgeInsets.only(top: topPadding, right: 8),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: BonfireThemeExtension.of(context).background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(8),
          ),
          border: Border(
            right: BorderSide(
              color: BonfireThemeExtension.of(context).foreground,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  List<Widget> listItems = [];

                  if (guildBannerUrl != null) {
                    listItems.add(
                      SizedBox(
                        height: 150,
                        child: Image.network(
                          "$guildBannerUrl?size=512",
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }

                  listItems.add(
                    StickyHeader(
                      header: GuildOverview(guildId: widget.guildId),
                      content: const SizedBox(height: 8),
                    ),
                  );

                  for (var channel in channelsWithoutParent) {
                    listItems.add(
                      ChannelButton(
                        currentChannelId: widget.channelId,
                        currentGuildId: widget.guildId,
                        channel: channel as GuildChannel,
                      ),
                    );
                  }

                  categoryMap.forEach((category, children) {
                    listItems.add(
                      Category(
                        guildId: widget.guildId,
                        channelId: widget.channelId,
                        category: category,
                        children: children,
                      ),
                    );
                  });

                  if (shouldUseMobileLayout(context)) {
                    listItems.add(
                      SizedBox(
                        height: MediaQuery.paddingOf(context).bottom + 50,
                      ),
                    );
                  }

                  return ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(8),
                    ),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false),
                      child: ListView(
                        key: ValueKey(widget.guildId.toString()),
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: listItems,
                      ),
                    ),
                  );
                },
              ),
            ),
            shouldUseDesktopLayout(context)
                ? const Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      bottom: 8.0,
                    ),
                    child: UserCard(),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
