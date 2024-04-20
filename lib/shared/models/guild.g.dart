// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Guild _$GuildFromJson(Map<String, dynamic> json) => Guild(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: Guild._imageFromJson(json['icon'] as String),
    );

Map<String, dynamic> _$GuildToJson(Guild instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': Guild._imageToJson(instance.icon),
    };
