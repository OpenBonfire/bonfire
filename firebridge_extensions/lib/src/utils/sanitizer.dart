import "package:firebridge/firebridge.dart";
import "package:firebridge_extensions/src/extensions/snowflake_entity.dart";

const _whitespaceCharacter = "‎";

/// A pattern that matches user mentions in a message.
final userMentionRegex = RegExp(r"<@!?(\d+)>");

/// A pattern that matches role mentions in a message.
final roleMentionRegex = RegExp(r"<@&(\d+)>");

/// A pattern that matches `@everyone` and `@here` mentions in a message.
final everyoneMentionRegex = RegExp("@(everyone|here)");

/// A pattern that matches channel mentions in a message.
final channelMentionRegex = RegExp(r"<#(\d+)>");

/// A pattern that matches guild emojis in a message.
final guildEmojiRegex = RegExp(r"<(a?):(\w+):(\d+)>");

/// A type of target [sanitizeContent] can operate on.
enum SanitizerTarget {
  /// Sanitize user mentions that match [userMentionRegex].
  users,

  /// Sanitize role mentions that match [roleMentionRegex].
  roles,

  /// Sanitize `@everyone` and `@here` mentions that match [everyoneMentionRegex].
  everyone,

  /// Sanitize channel mentions that match [channelMentionRegex].
  channels,

  /// Sanitize guild emojis that match [guildEmojiRegex].
  emojis,
}

/// An action [sanitizeContent] can take on a target.
enum SanitizerAction {
  /// Leave the target as-is.
  ignore,

  /// Remove the target completely.
  remove,

  /// Replace the target with its name and a prefix/suffix to indicate the target type.
  name,

  /// Replace the target with its name.
  nameNoPrefix,

  /// Insert an invisible character into the target to prevent Discord from parsing it.
  sanitize,
}

/// Find [SanitizerTarget]s in [content] and sanitize them according to [action].
///
/// [channel] must be provided as the channel to which the sanitized content will be sent. It is used to resolve user, role and channel IDs to their names.
///
/// [actionOverrides] can be provided to change the action taken for each [SanitizerTarget] type.
Future<String> sanitizeContent(
  String content, {
  required PartialTextChannel channel,
  SanitizerAction action = SanitizerAction.sanitize,
  Map<SanitizerTarget, SanitizerAction>? actionOverrides,
}) async {
  final client = channel.manager.client;
  final guild = await switch (await channel.get()) {
    GuildChannel(:final guild) => guild.get(),
    _ => null,
  };

  RegExp patternForTarget(SanitizerTarget target) => switch (target) {
        SanitizerTarget.users => userMentionRegex,
        SanitizerTarget.roles => roleMentionRegex,
        SanitizerTarget.everyone => everyoneMentionRegex,
        SanitizerTarget.channels => channelMentionRegex,
        SanitizerTarget.emojis => guildEmojiRegex,
      };

  Future<String> name(Match match, SanitizerTarget target) async =>
      switch (target) {
        SanitizerTarget.everyone => match.group(1)!,
        SanitizerTarget.channels => switch (await client
              .channels[Snowflake.parse(match.group(1)!)]
              .getOrNull()) {
            GuildChannel(:final name) || GroupDmChannel(:final name) => name,
            DmChannel(:final recipients) =>
              recipients.first.globalName ?? recipients.first.username,
            _ => 'Unknown Channel',
          },
        SanitizerTarget.roles => switch (await guild
              ?.roles[Snowflake.parse(match.group(1)!)]
              .getOrNull()) {
            Role(:final name) => name,
            _ => 'Unknown Role',
          },
        SanitizerTarget.users => switch (await guild
              ?.members[Snowflake.parse(match.group(1)!)]
              .getOrNull()) {
            Member(:final nick?) => nick,
            Member(:final user?) => user.globalName ?? user.username,
            _ => switch (await client.users[Snowflake.parse(match.group(1)!)]
                  .getOrNull()) {
                User(:final username, :final globalName) =>
                  globalName ?? username,
                _ => 'Unknown User',
              },
          },
        SanitizerTarget.emojis => match.group(2)!,
      };

  String prefix(SanitizerTarget target) => switch (target) {
        SanitizerTarget.users || SanitizerTarget.roles => '@',
        SanitizerTarget.everyone => '@$_whitespaceCharacter',
        SanitizerTarget.channels => '#',
        SanitizerTarget.emojis => '',
      };

  String suffix(SanitizerTarget target) =>
      target == SanitizerTarget.emojis ? ':' : '';

  Future<String> resolve(
          Match match, SanitizerTarget target, SanitizerAction action) async =>
      switch (action) {
        SanitizerAction.ignore => match.group(0)!,
        SanitizerAction.remove => '',
        SanitizerAction.nameNoPrefix => await name(match, target),
        SanitizerAction.name =>
          '${prefix(target)}${await name(match, target)}${suffix(target)}',
        SanitizerAction.sanitize => switch (target) {
            SanitizerTarget.users =>
              '<@$_whitespaceCharacter${match.group(1)!}>',
            SanitizerTarget.roles =>
              '<@&$_whitespaceCharacter${match.group(1)!}>',
            SanitizerTarget.everyone =>
              '@$_whitespaceCharacter${match.group(1)!}',
            SanitizerTarget.channels =>
              '<#$_whitespaceCharacter${match.group(1)!}>',
            SanitizerTarget.emojis =>
              '<$_whitespaceCharacter${match.group(1) ?? ''}:${match.group(2)}:${match.group(3)}>',
          },
      };

  String result = content;
  for (final target in SanitizerTarget.values) {
    final targetAction = actionOverrides?[target] ?? action;
    final pattern = patternForTarget(target);

    int shift = 0;

    for (final match in pattern.allMatches(result)) {
      final sanitized = await resolve(match, target, targetAction);

      result = result.replaceRange(
          match.start - shift, match.end - shift, sanitized);

      shift += (match.end - match.start) - sanitized.length;
    }
  }

  return result;
}
