// import 'package:firebridge/src/models/channel/channel.dart';
// import 'package:firebridge/src/models/channel/text_channel.dart';
// import 'package:firebridge/src/models/snowflake.dart';
// import 'package:firebridge/src/models/user/user.dart';

// /// Private channel. Used for direct messaging.
// abstract class PrivateChannel extends PartialTextChannel implements Channel {
//   List<dynamic>? safetyWarnings;
//   bool? isSpam;
//   Snowflake? lastMessageId;
//   List<User> recipients;
//   int flags;

//   PrivateChannel({
//     required super.id,
//     required super.json,
//     required super.manager,
//     this.safetyWarnings,
//     this.isSpam,
//     this.lastMessageId,
//     required this.recipients,
//     required this.flags,
//   });
// }
