import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bonfire/shared/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.g.dart';

@JsonSerializable()
class BonfireGuildMember {
  final int id;
  final int guildId;
  final String name;
  final String iconUrl;
  final String displayName;
  final String? nickName;

  // serialize / deserialize Image object
  // @JsonKey(fromJson: Utils.imageFromJson, toJson: Utils.imageToJson) doesn't work...

  // we don't really want to encode this anyways, since we'll be storing multiple instances

  @JsonKey(includeFromJson: false, includeToJson: false)
  Image? icon;

  BonfireGuildMember({
    required this.id,
    required this.guildId,
    required this.displayName,
    required this.name,
    required this.iconUrl,
    this.nickName,
    this.icon,
  });

  factory BonfireGuildMember.fromJson(Map<String, dynamic> json) =>
      _$BonfireGuildMemberFromJson(json);

  Map<String, dynamic> toJson() => _$BonfireGuildMemberToJson(this);
}
