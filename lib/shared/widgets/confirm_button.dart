import 'package:bonfire/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmButton extends StatefulWidget {
  final String text;
  final void Function() onPressed;

  const ConfirmButton({super.key, required this.text, required this.onPressed});

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: widget.onPressed,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).custom.colorTheme.blurple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
