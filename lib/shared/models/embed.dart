import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'embed.g.dart';

enum EmbedType {
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
  @JsonValue('audio')
  audio,
  @JsonValue('file')
  file,
}

@JsonSerializable()
class BonfireEmbed {
  final EmbedType type;
  final int? width;
  final int? height;
  final String? thumbnailUrl;
  final String? imageUrl;
  final String? title;
  final String? description;
  final String? provider;
  final String? videoUrl;
  final String? proxiedUrl;
  @ColorConverter()
  final Color? color;

  BonfireEmbed({
    required this.type,
    this.width,
    this.height,
    this.thumbnailUrl,
    this.imageUrl,
    this.title,
    this.description,
    this.provider,
    this.videoUrl,
    this.proxiedUrl,
    this.color,
  });

  factory BonfireEmbed.fromJson(Map<String, dynamic> json) =>
      _$BonfireEmbedFromJson(json);

  Map<String, dynamic> toJson() => _$BonfireEmbedToJson(this);
}

class ColorConverter implements JsonConverter<Color?, int?> {
  const ColorConverter();

  @override
  Color? fromJson(int? json) {
    return json != null ? Color(json) : null;
  }

  @override
  int? toJson(Color? object) {
    return object?.value;
  }
}
