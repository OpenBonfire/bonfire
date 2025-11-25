import 'dart:typed_data';

import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'image.g.dart';

@Riverpod(keepAlive: true)
Future<Uint8List?> attachedImage(Ref ref, Attachment attachment) async {
  return (await http.get(attachment.url)).bodyBytes;
}

@riverpod
Future<Uint8List?> embeddedImage(Ref ref, Embed embed) async {
  return (await http.get(embed.url!)).bodyBytes;
}
