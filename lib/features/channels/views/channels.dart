import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/channels.dart';
import 'package:bonfire/shared/models/channel.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';

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

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(36)),
          color: Theme.of(context).custom.colorTheme.foreground,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 12),
          itemCount: channelsWithoutParent.length + categoryMap.length,
          itemBuilder: (context, index) {
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
                return null;
              }
            }
          },
        ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 2, left: 8, right: 30),
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
              foregroundColor: Theme.of(context).custom.colorTheme.textColor1,
              backgroundColor: (widget.channel.id == channelController)
                  ? Theme.of(context).custom.colorTheme.cardSelected
                  : Colors.transparent),
          onPressed: () {
            ref
                .read(channelControllerProvider.notifier)
                .setChannel(widget.channel.id);
          },
          child: SizedBox(
            height: 35,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(widget.channel.name,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).custom.textTheme.bodyText2),
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
