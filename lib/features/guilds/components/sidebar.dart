import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuildSidebar extends ConsumerStatefulWidget {
  const GuildSidebar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GuildSidebarState();
}

class _GuildSidebarState extends ConsumerState<GuildSidebar> {
  @override
  Widget build(BuildContext context) {
    final guildIds = ref.watch(guildIdsProvider);
    return CustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: guildIds.length,
          itemBuilder: (context, index) {
            return Text(guildIds[index].toString());
          },
        ),
      ],
    );
  }
}
