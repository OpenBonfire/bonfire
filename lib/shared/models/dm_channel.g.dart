// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BonfireDMChannel _$BonfireDMChannelFromJson(Map<String, dynamic> json) =>
    BonfireDMChannel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      icon: Utils.imageFromJson(json['icon'] as String),
    );

Map<String, dynamic> _$BonfireDMChannelToJson(BonfireDMChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': Utils.imageToJson(instance.icon),
    };
