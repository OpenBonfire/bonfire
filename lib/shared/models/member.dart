import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bonfire/shared/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.g.dart';

@JsonSerializable()
class BonfireMember {
  final int id;
  final String name;

  // serialize / deserialize Image object
  // @JsonKey(fromJson: Utils.imageFromJson, toJson: Utils.imageToJson) doesn't work...

  // we don't really want to encode this anyways, since we'll be storing multiple instances

  @JsonKey(includeFromJson: false, includeToJson: false)
  Image? icon;

  BonfireMember({
    required this.id,
    required this.name,
    this.icon,
  });

  factory BonfireMember.fromJson(Map<String, dynamic> json) =>
      _$BonfireMemberFromJson(json);

  Map<String, dynamic> toJson() => _$BonfireMemberToJson(this);
}
