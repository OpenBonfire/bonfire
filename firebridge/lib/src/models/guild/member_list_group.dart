import 'package:firebridge/src/models/snowflake.dart';

class GuildMemberListGroup {
  final Snowflake? id;

  /// The name of the group, if applicable. (Ex: "online")
  final String? name;
  final int? count;

  GuildMemberListGroup({
    this.id,
    this.name,
    this.count,
  });
}
