// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BonfireEmbed _$BonfireEmbedFromJson(Map<String, dynamic> json) => BonfireEmbed(
      type: $enumDecode(_$EmbedTypeEnumMap, json['type']),
      thumbnailWidth: json['thumbnailWidth'] as int?,
      thumbnailHeight: json['thumbnailHeight'] as int?,
      contentWidth: json['contentWidth'] as int?,
      contentHeight: json['contentHeight'] as int?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      provider: json['provider'] as String?,
      videoUrl: json['videoUrl'] as String?,
      proxiedUrl: json['proxiedUrl'] as String?,
      color: const ColorConverter().fromJson(json['color'] as int?),
    );

Map<String, dynamic> _$BonfireEmbedToJson(BonfireEmbed instance) =>
    <String, dynamic>{
      'type': _$EmbedTypeEnumMap[instance.type]!,
      'contentWidth': instance.contentWidth,
      'contentHeight': instance.contentHeight,
      'thumbnailWidth': instance.thumbnailWidth,
      'thumbnailHeight': instance.thumbnailHeight,
      'thumbnailUrl': instance.thumbnailUrl,
      'imageUrl': instance.imageUrl,
      'title': instance.title,
      'description': instance.description,
      'provider': instance.provider,
      'videoUrl': instance.videoUrl,
      'proxiedUrl': instance.proxiedUrl,
      'color': const ColorConverter().toJson(instance.color),
    };

const _$EmbedTypeEnumMap = {
  EmbedType.image: 'image',
  EmbedType.video: 'video',
  EmbedType.audio: 'audio',
  EmbedType.file: 'file',
};
