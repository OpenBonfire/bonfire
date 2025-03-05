import 'package:bonfire/features/messaging/controllers/message.dart';
import 'package:bonfire/features/messaging/repositories/reactions.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageReactions extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake messageId;

  const MessageReactions({
    super.key,
    required this.guildId,
    required this.messageId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MessageReactionsState();
}

class _MessageReactionsState extends ConsumerState<MessageReactions> {
  @override
  Widget build(BuildContext context) {
    final reactions = ref.watch(messageReactionsProvider(
      // widget.guildId,
      widget.messageId,
    ));
    if (reactions == null) {
      return Container();
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var reaction in reactions)
          ReactionWidget(
            reaction: reaction,
            messageId: widget.messageId,
          ),
      ],
    );
  }
}

class ReactionWidget extends ConsumerWidget {
  final Reaction reaction;
  final Snowflake messageId;
  const ReactionWidget({
    super.key,
    required this.reaction,
    required this.messageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).custom;

    return Container(
      height: 36,
      // width: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: reaction.me ? theme.colorTheme.blurple.withOpacity(0.2) : null,
        border: Border.all(
          color: reaction.me
              ? theme.colorTheme.blurple
              : theme.colorTheme.foreground,
        ),
      ),
      child: InkWell(
        onTap: () async {
          final message = ref.read(messageControllerProvider(messageId));
          if (reaction.me) {
            message!.deleteOwnReaction(
                ReactionBuilder.fromEmoji(reaction.emoji as Emoji));
          } else {
            message!.react(ReactionBuilder.fromEmoji(reaction.emoji as Emoji));
          }

          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.only(
            right: 8,
            left: 4,
            // top: 2,
            // bottom: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 4,
            children: [
              (reaction.emoji is TextEmoji)
                  ? SizedBox(
                      child: Text((reaction.emoji as TextEmoji).name,
                          style:
                              Theme.of(context).custom.textTheme.titleMedium),
                    )
                  : Image.network(
                      (reaction.emoji as GuildEmoji).image.url.toString(),
                      width: 20,
                      height: 20,
                    ),
              Text(
                reaction.count.toString(),
                style: Theme.of(context).custom.textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
