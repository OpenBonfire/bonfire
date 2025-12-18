import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reactions.g.dart';

@Riverpod(keepAlive: true)
class MessageReactions extends _$MessageReactions {
  @override
  List<Reaction>? build(Snowflake messageId) {
    return null;
  }

  void setReactions(List<Reaction> reactions) {
    state = reactions;
  }

  void addReaction(
    Emoji emoji,
    PartialUser user,
    List<DiscordColor>? burstColors,
  ) async {
    final client = ref.watch(clientControllerProvider)!;
    List<Reaction> newReactions = [];
    List<Reaction> reactions = state?.toList() ?? [];

    // copy reactions
    newReactions = reactions.toList();
    for (var r in reactions) {
      String name = "";
      if (r.emoji is TextEmoji) {
        // name = (r.emoji as TextEmoji).name;
      } else if (r.emoji is GuildEmoji) {
        name = (r.emoji as GuildEmoji).name!;
      }

      if (emoji.name == name) {
        var newReaction = Reaction(
          count: r.count + 1,
          countDetails: r.countDetails,
          me: r.me || user.id == client.user.id,
          meBurst: r.meBurst,
          emoji: r.emoji,
          // burstColors: burstColors ?? r.burstColors,
          burstColors: r.burstColors,
        );
        newReactions[reactions.indexOf(r)] = newReaction;
        reactions = newReactions;
        state = newReactions;
        return;
      }
    }

    newReactions.add(
      Reaction(
        count: 1,
        countDetails: ReactionCountDetails(burst: 0, normal: 0),
        me: user.id == client.user.id,
        meBurst: false,
        emoji: emoji.id!,
        burstColors: [],
      ),
    );
    reactions = newReactions;
    state = reactions;
  }

  void removeReaction(Emoji emoji, PartialUser user) {
    final client = ref.watch(clientControllerProvider)!;

    List<Reaction> newReactions = state?.toList() ?? [];
    final reactions = state?.toList() ?? [];

    for (var r in reactions) {
      String name = "";
      if (r.emoji is TextEmoji) {
        // name = (r.emoji as TextEmoji).name;
      } else if (r.emoji is GuildEmoji) {
        name = (r.emoji as GuildEmoji).name!;
      }

      if (emoji.name == name) {
        if (r.count <= 1) {
          newReactions.remove(r);
        } else {
          var newReaction = Reaction(
            count: r.count - 1,
            countDetails: r.countDetails,
            me: r.me && user.id != client.user.id,
            meBurst: r.meBurst && user.id != client.user.id,
            emoji: r.emoji,
            burstColors: r.burstColors,
          );
          newReactions[reactions.indexOf(r)] = newReaction;
        }
        state = newReactions;
        return;
      }
    }
  }

  /// Check if the user has reacted to the message
  bool hasReacted(Emoji emoji) {
    final reactions = state?.toList() ?? [];
    for (var r in reactions) {
      String name = "";
      if (r.emoji is TextEmoji) {
        // name = (r.emoji as TextEmoji).name;
      } else if (r.emoji is GuildEmoji) {
        name = (r.emoji as GuildEmoji).name!;
      }

      if (emoji.name == name && r.me) {
        return true;
      }
    }
    return false;
  }
}
