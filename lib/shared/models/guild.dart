import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bonfire/shared/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'guild.g.dart';

@JsonSerializable()
class Guild {
  final int id;
  final String name;
  @JsonKey(fromJson: Utils.imageFromJson, toJson: Utils.imageToJson)
  final Image? icon;

  Guild({
    required this.id,
    required this.name,
    this.icon,
  });

  factory Guild.fromJson(Map<String, dynamic> json) => _$GuildFromJson(json);

  Map<String, dynamic> toJson() => _$GuildToJson(this);
}