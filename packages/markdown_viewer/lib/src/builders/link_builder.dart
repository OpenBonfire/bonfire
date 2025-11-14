import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../definition.dart';
import 'builder.dart';

class LinkBuilder extends MarkdownElementBuilder {
  LinkBuilder({
    TextStyle? textStyle,
    MarkdownTapLinkCallback? onTap,
  })  : _onTap = onTap,
        super(
          textStyle: const TextStyle(
            color: Color(0xff2196f3),
          ).merge(textStyle),
        );

  @override
  final matchTypes = ['link'];

  final MarkdownTapLinkCallback? _onTap;

  @override
  GestureRecognizer? gestureRecognizer(element) {
    if (_onTap == null) {
      return null;
    }
    final attributes = element.attributes;

    return TapGestureRecognizer()
      ..onTap = () {
        _onTap!(
          attributes['destination'],
          attributes['title'],
        );
      };
  }
}
