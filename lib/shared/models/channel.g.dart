// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BonfireChannel _$BonfireChannelFromJson(Map<String, dynamic> json) =>
    BonfireChannel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: $enumDecode(_$BonfireChannelTypeEnumMap, json['type']),
      position: json['position'] as int,
      parent: json['parent'] == null
          ? null
          : BonfireChannel.fromJson(json['parent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BonfireChannelToJson(BonfireChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$BonfireChannelTypeEnumMap[instance.type]!,
      'position': instance.position,
      'parent': instance.parent,
    };

const _$BonfireChannelTypeEnumMap = {
  BonfireChannelType.guildText: 'guildText',
  BonfireChannelType.dm: 'dm',
  BonfireChannelType.guildVoice: 'guildVoice',
  BonfireChannelType.groupDm: 'groupDm',
  BonfireChannelType.guildCategory: 'guildCategory',
  BonfireChannelType.guildAnnouncement: 'guildAnnouncement',
  BonfireChannelType.announcementThread: 'announcementThread',
  BonfireChannelType.publicThread: 'publicThread',
  BonfireChannelType.privateThread: 'privateThread',
  BonfireChannelType.guildStageVoice: 'guildStageVoice',
  BonfireChannelType.guildDirectory: 'guildDirectory',
  BonfireChannelType.guildForum: 'guildForum',
  BonfireChannelType.guildMedia: 'guildMedia',
};
