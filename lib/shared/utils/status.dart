import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';

// This kinda sucks. I should probably make a widget that handles stuff like
// icons as well.

Color getStatusColor(BuildContext context, UserStatus status) {
  switch (status) {
    case UserStatus.online:
      return Theme.of(context).custom.colorTheme.green;
    case UserStatus.idle:
      return Theme.of(context).custom.colorTheme.yellow;
    case UserStatus.dnd:
      return Theme.of(context).custom.colorTheme.red;
    case UserStatus.offline:
      return Theme.of(context).custom.colorTheme.darkButtonBackground;
  }
}
