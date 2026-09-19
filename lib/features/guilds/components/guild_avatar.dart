import 'package:bonfire/features/media/components/image.dart';
import 'package:bonfire/shared/utils/guild_abbreviation.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';

class GuildAvatar extends StatelessWidget {
  final Guild guild;
  final FirebridgeGateway client;
  final BorderRadius? borderRadius;
  const GuildAvatar({
    super.key,
    required this.guild,
    required this.client,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final icon = guild.icon;
    if (icon != null) {
      return DiscordNetworkImage(
        icon.getUrl(client).toString(),
        fit: BoxFit.cover,
        borderRadius: borderRadius,
      );
    }

    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            guildAbbreviation(guild.name),
            maxLines: 1,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
