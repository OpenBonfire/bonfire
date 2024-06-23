import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/channels.dart';
import 'package:bonfire/features/guild/views/guild_overview.dart';
// import 'package:bonfire/features/guild/views/guild_overview.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/shared/utils/icons.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart' hide Builder;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'package:sticky_headers/sticky_headers.dart';

class ChannelsList extends ConsumerStatefulWidget {
  const ChannelsList({super.key});

  @override
  ConsumerState<ChannelsList> createState() => _ChannelsListState();
}

class _ChannelsListState extends ConsumerState<ChannelsList> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).padding.top;
    var channelWatch = ref.watch(channelsProvider);

    var channels = channelWatch.valueOrNull ?? [] ;

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
        var channel = channelsWithoutParent[index];
        return ChannelButton(channel: channel as GuildChannel);
      } else {
        var categoryIndex = index - channelsWithoutParent.length;
        var category = categoryMap.keys.elementAt(categoryIndex);
        var children = categoryMap[category] ?? [];
        if (category != null) {
          return Category(category: category, children: children);
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
          color: Theme.of(context).custom.colorTheme.foreground,
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
                    Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 68, 69, 74),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(12)),
                      ),
                    ),
                    StickyHeader(
                      header: const GuildOverview(),
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

class ChannelButton extends ConsumerStatefulWidget {
  GuildChannel channel;
  ChannelButton({super.key, required this.channel});

  @override
  ConsumerState<ChannelButton> createState() => _ChannelButtonState();
}

class _ChannelButtonState extends ConsumerState<ChannelButton> {
  Map<int, Widget> categoryMap = {};

  @override
  Widget build(BuildContext context) {
    var channelController = ref.watch(channelControllerProvider);
    bool selected = widget.channel == channelController;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2, left: 8, right: 10),
      child: SizedBox(
        width: double.infinity,
        height: 35,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              side: BorderSide(
                color: (widget.channel == channelController)
                    ? Theme.of(context).custom.colorTheme.brightestGray
                    : Colors.transparent,
                width: 0.3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: selected
                  ? Theme.of(context).custom.colorTheme.textColor1
                  : Theme.of(context).custom.colorTheme.textColor2,
              backgroundColor: selected
                  ? Theme.of(context).custom.colorTheme.cardSelected
                  : Colors.transparent),
          onPressed: () {
            ref
                .read(channelControllerProvider.notifier)
                .setChannel(widget.channel);

            OverlappingPanelsState? overlappingPanelsState =
                OverlappingPanels.of(context);
            if (overlappingPanelsState != null) {
              overlappingPanelsState.moveToState(RevealSide.main);
            }
          },
          child: SizedBox(
            height: 35,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    BonfireIcons.channelIcons[widget.channel.type]!,
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(widget.channel.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            textAlign: TextAlign.left,
                            style: Theme.of(context)
                                .custom
                                .textTheme
                                .bodyText1
                                .copyWith(
                                  color: selected
                                      ? Theme.of(context)
                                          .custom
                                          .colorTheme
                                          .textColor1
                                      : Theme.of(context)
                                          .custom
                                          .colorTheme
                                          .textColor2,
                                ))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Category extends StatefulWidget {
  final GuildChannel category;
  final List<GuildChannel> children;

  const Category({super.key, required this.category, required this.children});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: SizedBox(
              height: 25,
              child: Text(widget.category.name.toUpperCase(),
                  style: GoogleFonts.inriaSans(
                    color: const Color.fromARGB(189, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ),
          SizedBox(
            child: Column(
              children: widget.children
                  .map((channel) => ChannelButton(channel: channel))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
