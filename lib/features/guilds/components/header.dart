import 'dart:math';

import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuildOverview extends ConsumerWidget {
  final Snowflake guildId;
  const GuildOverview({super.key, required this.guildId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final guild = ref.watch(guildProvider(guildId));
    String guildTitle = guild?.name ?? "Not in a server";

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(8),
          ),
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.surfaceContainer,
              width: 1.0,
            ),
          ),
        ),
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
                        style: Theme.of(context).textTheme.titleSmall!,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.rotate(
                      angle: pi / 2,
                      child: const Icon(Icons.expand_less_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
