import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/channels/components/category.dart';
import 'package:bonfire/features/channels/components/channel_button.dart';
import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:bonfire/features/guilds/components/header.dart';
import 'package:bonfire/features/media/components/image.dart';
import 'package:bonfire/features/voice/controllers/voice_connection.dart';
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
            child: _buildChannelButton(
              ref,
              context,
              guildId,
              channel,
              selectedChannel,
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
                        (e) => _buildChannelButton(
                          ref,
                          context,
                          guildId,
                          e,
                          selectedChannel,
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
  bool shouldRebuild(covariant SectionHeaderDelegate oldDelegate) =>
      guildId != oldDelegate.guildId;
}

/// Voice channels join/leave the current voice connection instead of
/// navigating; everything else behaves like a text channel.
Widget _buildChannelButton(
  WidgetRef ref,
  BuildContext context,
  Snowflake guildId,
  GuildChannel channel,
  String? selectedChannel,
) {
  if (channel is GuildVoiceChannel) {
    final connectedChannelId = ref.watch(voiceConnectionControllerProvider).channelId;
    final connected = connectedChannelId == channel.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChannelButton(
          name: channel.name,
          icon: const Icon(Icons.volume_up_rounded),
          selected: connected,
          onPressed: () {
            HapticFeedback.lightImpact();
            final controller = ref.read(
              voiceConnectionControllerProvider.notifier,
            );
            if (connected) {
              controller.leave();
            } else {
              controller.join(guildId, channel.id);
            }
          },
        ),
        _VoiceChannelMembers(channelId: channel.id),
      ],
    );
  }

  return ChannelButton(
    name: channel.name,
    icon: const Icon(Icons.numbers_rounded),
    selected: channel.id.toString() == selectedChannel,
    hasUnreads: ref.watch(channelHasUnreadsProvider(channel.id)),
    onPressed: () {
      HapticFeedback.lightImpact();
      context.go("/channels/$guildId/${channel.id}");
    },
  );
}

/// The users currently connected to a voice channel. Just names for now -
/// enough to see who's in there.
class _VoiceChannelMembers extends ConsumerWidget {
  final Snowflake channelId;
  const _VoiceChannelMembers({required this.channelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIds = ref.watch(channelVoiceStateUserIdsProvider(channelId));
    if (userIds.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final userId in userIds)
            _VoiceChannelMember(userId: userId, theme: theme),
        ],
      ),
    );
  }
}

class _VoiceChannelMember extends ConsumerWidget {
  final Snowflake userId;
  final ThemeData theme;
  const _VoiceChannelMember({required this.userId, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider(userId));
    return Text(
      user?.globalName ?? user?.username ?? userId.toString(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
