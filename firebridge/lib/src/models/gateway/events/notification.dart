import 'package:firebridge/src/models/channel/channel.dart';
import 'package:firebridge/src/models/message/message.dart';
import 'package:firebridge/src/models/snowflake.dart';

class NotificationCreatedEvent {
  String userAvatar;
  Snowflake notifInstanceId;
  MessageType messageType;
  String username;
  Snowflake messageId;
  Snowflake recievingUserId;
  String eventType;
  Message message;
  MessageFlags messageFlags;
  String messageContent;
  Snowflake userId;
  String category;
  String sound;
  ChannelType channelType;
  Snowflake channelId;
  int notifTypeId;

  NotificationCreatedEvent({
    required this.userAvatar,
    required this.notifInstanceId,
    required this.messageType,
    required this.username,
    required this.messageId,
    required this.recievingUserId,
    required this.eventType,
    required this.message,
    required this.messageFlags,
    required this.messageContent,
    required this.userId,
    required this.category,
    required this.sound,
    required this.channelType,
    required this.channelId,
    required this.notifTypeId,
  });
}
