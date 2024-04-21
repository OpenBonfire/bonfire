import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Utils {
  static Image imageFromJson(String base64String) {
    print("DECODING: ");
    print(base64String);
    Uint8List bytes = base64.decode(base64String);
    return Image.memory(bytes);
  }

  static Future<String?> imageToJson(Image? icon) async {
    if (icon == null) return null;

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
