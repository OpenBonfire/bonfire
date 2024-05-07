// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BonfireEmbed _$BonfireEmbedFromJson(Map<String, dynamic> json) => BonfireEmbed(
      type: $enumDecode(_$EmbedTypeEnumMap, json['type']),
      width: json['width'] as int?,
      height: json['height'] as int?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      color: const ColorConverter().fromJson(json['color'] as int?),
    );

Map<String, dynamic> _$BonfireEmbedToJson(BonfireEmbed instance) =>
    <String, dynamic>{
      'type': _$EmbedTypeEnumMap[instance.type]!,
      'width': instance.width,
      'height': instance.height,
      'thumbnailUrl': instance.thumbnailUrl,
      'color': const ColorConverter().toJson(instance.color),
    };

const _$EmbedTypeEnumMap = {
  EmbedType.image: 'image',
  EmbedType.video: 'video',
  EmbedType.audio: 'audio',
  EmbedType.file: 'file',
};
