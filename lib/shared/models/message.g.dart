// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BonfireMessage _$BonfireMessageFromJson(Map<String, dynamic> json) =>
    BonfireMessage(
      id: json['id'] as int,
      channelId: json['channelId'] as int,
      content: json['content'] as String,
      member:
          BonfireGuildMember.fromJson(json['member'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$BonfireMessageToJson(BonfireMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'member': instance.member,
    };
