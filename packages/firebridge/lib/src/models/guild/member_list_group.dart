import 'package:firebridge/src/models/gateway/opcode.dart';
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

class MemberListUpdateOperation {
  final MemberListUpdateType type;
  final dynamic data;
  final int? index;
  final List<int>? range;

  MemberListUpdateOperation({
    required this.type,
    required this.data,
    this.index,
    this.range,
  });
}
