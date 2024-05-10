// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Guild _$GuildFromJson(Map<String, dynamic> json) => Guild(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      icon: Utils.imageFromJson(json['icon'] as String),
    );

Map<String, dynamic> _$GuildToJson(Guild instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': Utils.imageToJson(instance.icon),
    };
