import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reactions.g.dart';

@Riverpod(keepAlive: true)
class MessageReactions extends _$MessageReactions {
  AuthUser? user;
  List<Reaction> reactions = [];

  @override
  List<Reaction>? build(Snowflake messageId) {
    var auth = ref.watch(authProvider);

    if (auth is AuthUser) {
      user = auth;
      return null;
    }

    return null;
  }

  void setReactions(List<Reaction> reactions) {
    this.reactions = reactions;
    state = reactions;
  }

  void addReaction(
    Emoji emoji,
    PartialUser user,
    List<DiscordColor>? burstColors,
  ) async {
    List<Reaction> newReactions = [];

    // copy reactions
    newReactions = List.from(reactions);
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
          me: r.me || user.id == this.user!.client.user.id,
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

    // newReactions.add(
    //   Reaction(
    //     count: 1,
    //     countDetails: ReactionCountDetails(burst: 0, normal: 0),
    //     me: user.id == this.user!.client.user.id,
    //     meBurst: false,
    //     emoji: emoji,
    //     burstColors: [],
    //   ),
    // );
    reactions = newReactions;
    state = reactions;
  }

  void removeReaction(Emoji emoji, PartialUser user) {
    List<Reaction> newReactions = [];
    // copy reactions
    newReactions = List.from(reactions);

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
            me: r.me && user.id != this.user!.client.user.id,
            meBurst: r.meBurst && user.id != this.user!.client.user.id,
            emoji: r.emoji,
            burstColors: r.burstColors,
          );
          newReactions[reactions.indexOf(r)] = newReaction;
        }

        reactions = newReactions;
        state = newReactions;
        return;
      }
    }
  }

  /// Check if the user has reacted to the message
  bool hasReacted(Emoji emoji) {
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
