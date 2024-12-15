import 'package:bonfire/theme/theme.dart';
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
        return Container(
          decoration: BoxDecoration(
              color: Theme.of(context).custom.colorTheme.background),
          height: screenHeight.keyboardHeight,
        );
      },
    );
  }
}
