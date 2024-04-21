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
  @JsonKey(fromJson: Utils.imageFromJson, toJson: Utils.imageToJson)
  final Image? icon;

  BonfireMember({
    required this.id,
    required this.name,
    this.icon,
  });

  factory BonfireMember.fromJson(Map<String, dynamic> json) =>
      _$BonfireMemberFromJson(json);

  Map<String, dynamic> toJson() => _$BonfireMemberToJson(this);
}
