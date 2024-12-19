import 'package:flutter/painting.dart';

import '../ast.dart';

/// Parses a block padding, including:
///
/// 1. Remove `top` when it is the first child.
/// 2. Remove `bottom` when it is the last child.
EdgeInsets? parseBlockPadding(EdgeInsets? padding, SiblingPosition position) {
  if (padding == null || padding == EdgeInsets.zero) {
    return null;
  }

  final isLast = position.index + 1 == position.total;
  final isFirst = position.index == 0;

  if (!isLast && !isFirst) {
    return padding;
  }

  var top = padding.top;
  var bottom = padding.bottom;

  if (isFirst && isLast) {
    top = 0;
    bottom = 0;
  } else if (isFirst) {
    top = 0;
  } else if (isLast) {
    bottom = 0;
  }

  return padding.copyWith(
    top: top,
    bottom: bottom,
    left: padding.left,
    right: padding.right,
  );
}
