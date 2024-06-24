import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart'
    as keyboard_size;
import 'package:flutter_keyboard_size/screen_height.dart';

class KeyboardBuffer extends StatefulWidget {
  const KeyboardBuffer({super.key});

  @override
  State<KeyboardBuffer> createState() => _KeyboardBufferState();
}

class _KeyboardBufferState extends State<KeyboardBuffer> {
  @override
  Widget build(BuildContext context) {
    return keyboard_size.Consumer<ScreenHeight>(
      builder: (context, screenHeight, child) {
        return SizedBox(
          height: screenHeight.keyboardHeight,
        );
      },
    );
  }
}
