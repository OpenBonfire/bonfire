// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BonfireGuildMember _$BonfireGuildMemberFromJson(Map<String, dynamic> json) =>
    BonfireGuildMember(
      id: (json['id'] as num).toInt(),
      guildId: (json['guildId'] as num).toInt(),
      displayName: json['displayName'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
      nickName: json['nickName'] as String?,
    );

Map<String, dynamic> _$BonfireGuildMemberToJson(BonfireGuildMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guildId': instance.guildId,
      'name': instance.name,
      'iconUrl': instance.iconUrl,
      'displayName': instance.displayName,
      'nickName': instance.nickName,
    };
