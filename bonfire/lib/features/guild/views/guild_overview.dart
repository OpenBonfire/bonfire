import 'dart:math';

import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuildOverview extends ConsumerStatefulWidget {
  final Snowflake guildId;
  const GuildOverview({super.key, required this.guildId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GuildOverviewState();
}

class _GuildOverviewState extends ConsumerState<GuildOverview> {
  @override
  Widget build(BuildContext context) {
    var guild = ref.watch(guildControllerProvider(widget.guildId));
    String guildTitle = guild?.name ?? "Not in a server";

    return SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).custom.colorTheme.channelListBackground,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(8)),
              border: Border(
                  bottom: BorderSide(
                      color: Theme.of(context).custom.colorTheme.foreground,
                      width: 1.0))),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          guildTitle,
                          style: CustomTextTheme().titleSmall.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.rotate(
                          angle: pi / 2,
                          child: const Icon(Icons.expand_less_rounded)),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              )
            ],
          ),
        ));
  }
}
