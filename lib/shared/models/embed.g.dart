// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BonfireEmbed _$BonfireEmbedFromJson(Map<String, dynamic> json) => BonfireEmbed(
      type: $enumDecode(_$EmbedTypeEnumMap, json['type']),
      thumbnailWidth: (json['thumbnailWidth'] as num?)?.toInt(),
      thumbnailHeight: (json['thumbnailHeight'] as num?)?.toInt(),
      contentWidth: (json['contentWidth'] as num?)?.toInt(),
      contentHeight: (json['contentHeight'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      provider: json['provider'] as String?,
      videoUrl: json['videoUrl'] as String?,
      proxiedUrl: json['proxiedUrl'] as String?,
      color: const ColorConverter().fromJson((json['color'] as num?)?.toInt()),
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
