import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bonfire/shared/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'embed.g.dart';

@JsonSerializable()
class BonfireEmbed {
  final int width;
  final int height;
  final String? thumbnailUrl;

  BonfireEmbed({
    required this.width,
    required this.height,
    this.thumbnailUrl,
  });

  factory BonfireEmbed.fromJson(Map<String, dynamic> json) =>
      _$BonfireEmbedFromJson(json);

  Map<String, dynamic> toJson() => _$BonfireEmbedToJson(this);
}
