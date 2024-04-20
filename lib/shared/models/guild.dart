import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'guild.g.dart';

@JsonSerializable()
class Guild {
  final int id;
  final String name;
  @JsonKey(fromJson: _imageFromJson, toJson: _imageToJson)
  final Image icon;

  Guild({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Guild.fromJson(Map<String, dynamic> json) => _$GuildFromJson(json);

  Map<String, dynamic> toJson() => _$GuildToJson(this);

  static Image _imageFromJson(String base64String) {
    if (base64String.isEmpty) {
      // todo: do this differently
      return Image.asset("assets/default_icon.png");
    }
    Uint8List bytes = base64.decode(base64String);
    return Image.memory(bytes);
  }

  static Future<String> _imageToJson(Image icon) async {
    Completer<String> completer = Completer();
    icon.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) async {
          final ByteData byteData =
              (await image.image.toByteData(format: ImageByteFormat.png))!;
          final Uint8List bytes = byteData.buffer.asUint8List();
          final String base64String = base64.encode(bytes);
          completer.complete(base64String);
        },
      ),
    );
    return completer.future;
  }
}
