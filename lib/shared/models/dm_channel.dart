import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bonfire/shared/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dm_channel.g.dart';

@JsonSerializable()
class BonfireDMChannel {
  final int id;
  final String name;
  @JsonKey(fromJson: Utils.imageFromJson, toJson: Utils.imageToJson)
  final Image? icon;

  BonfireDMChannel({
    required this.id,
    required this.name,
    this.icon,
  });

  factory BonfireDMChannel.fromJson(Map<String, dynamic> json) =>
      _$BonfireDMChannelFromJson(json);

  Map<String, dynamic> toJson() => _$BonfireDMChannelToJson(this);
}
