import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';

// This kinda sucks. I should probably make a widget that handles stuff like
// icons as well.

Color getStatusColor(BuildContext context, UserStatus status) {
  switch (status) {
    case UserStatus.online:
      return BonfireThemeExtension.of(context).green;
    case UserStatus.idle:
      return BonfireThemeExtension.of(context).yellow;
    case UserStatus.dnd:
      return BonfireThemeExtension.of(context).red;
    case UserStatus.offline:
      return BonfireThemeExtension.of(context).background;
    case UserStatus.custom:
      return BonfireThemeExtension.of(context).background;
  }
}
