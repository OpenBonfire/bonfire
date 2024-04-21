import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bonfire/shared/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.g.dart';

@JsonSerializable()
class Member {
  final int id;
  final String name;
  @JsonKey(fromJson: Utils.imageFromJson, toJson: Utils.imageToJson)
  final Image? icon;

  Member({
    required this.id,
    required this.name,
    this.icon,
  });

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);
}
