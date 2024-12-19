import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

/// A relationship between the current user and another user.
///
/// External references:
/// * Discord User API Reference: https://docs.discord.sex/resources/user#relationship-object
class Relationship with ToStringHelper {
  // in the api endpoint I believe this is a partial user, but this is for ready events.
  User user;
  int type;
  bool isSpamRequest;
  Snowflake id;
  String? nickname;
  DateTime? since;

  /// Create a new [Relationship].
  Relationship({
    required this.user,
    required this.type,
    required this.isSpamRequest,
    required this.id,
    this.nickname,
    this.since,
  });
}
