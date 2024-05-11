import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/channels.dart';
import 'package:bonfire/features/guild/views/guild_overview.dart';
// import 'package:bonfire/features/guild/views/guild_overview.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/shared/models/channel.dart';
import 'package:bonfire/shared/utils/icons.dart';
import 'package:bonfire/theme/theme.dart';
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
  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).padding.top;
    var channelWatch = ref.watch(channelsProvider);

    var channels = channelWatch.valueOrNull ?? [];

    var channelsWithoutParent = channels
        .where((channel) =>
            (channel.parent == null) &&
            (channel.type != BonfireChannelType.guildCategory))
        .toList();

    Map<int, List<BonfireChannel>> categoryMap = {};

    // group channels by category
    channels.forEach((channel) {
      if (channel.type == BonfireChannelType.guildCategory) {
        categoryMap[channel.id] = [];
      }
    });

    channels.forEach((channel) {
      if (channel.type != BonfireChannelType.guildCategory) {
        var parentChannel = categoryMap.keys.firstWhereOrNull(
          (element) => element == channel.parent?.id,
        );

        if (parentChannel != null) {
          categoryMap[parentChannel]!.add(channel);
        }
      }
    });

    Widget buildChannelButton(int index) {
      if (index < channelsWithoutParent.length) {
        var channel = channelsWithoutParent[index];
        return ChannelButton(channel: channel);
      } else {
        var categoryIndex = index - channelsWithoutParent.length;
        var categoryId = categoryMap.keys.elementAt(categoryIndex);
        var category = channels.firstWhereOrNull(
          (channel) => channel.id == categoryId,
        );
        var children = categoryMap[categoryId] ?? [];
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
            return ListView(children: [
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 68, 69, 74),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(12)
                  ),
                
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
              )
            ]);
          }),
        ),

        // return StickyHeader(
        //   header: (index == 0) ? const GuildOverview() : Container(),
        //   content: ret ?? Container(),
        // );
      ),
    );
  }
}

class ChannelButton extends ConsumerStatefulWidget {
  BonfireChannel channel;
  ChannelButton({super.key, required this.channel});

  @override
  ConsumerState<ChannelButton> createState() => _ChannelButtonState();
}

class _ChannelButtonState extends ConsumerState<ChannelButton> {
  Map<int, Widget> categoryMap = {};

  @override
  Widget build(BuildContext context) {
    var channelController = ref.watch(channelControllerProvider);
    bool selected = widget.channel.id == channelController;

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
                color: (widget.channel.id == channelController)
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
                .setChannel(widget.channel.id);

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
  final BonfireChannel category;
  final List<BonfireChannel> children;

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
              child: Text(widget.category.name,
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
