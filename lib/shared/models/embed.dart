import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'embed.g.dart';

@JsonSerializable()
class BonfireEmbed {
  final int? width;
  final int? height;
  final String? thumbnailUrl;
  @ColorConverter()
  final Color? color;

  BonfireEmbed({
    this.width,
    this.height,
    this.thumbnailUrl,
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
