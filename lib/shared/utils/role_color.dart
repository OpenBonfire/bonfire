import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

Color getRoleColor(Member member, List<Role> roles) {
  Role? topRole;
  Role? topEmojiRole;
  Color textColor = Colors.white;

  for (PartialRole partialRole in member.roles) {
    Role? role = roles.firstWhereOrNull((role) => partialRole.id == role.id);
    if (role == null) {
      continue;
    }
    topRole ??= role;

    if (role.icon != null) {
      topEmojiRole ??= role;
      if (topEmojiRole.position < role.position) {
        topEmojiRole = role;
      }
    }

    if (topRole.position < role.position) {
      topRole = role;
    }

    var tc = topRole.color;
    if (tc.value != 0) textColor = Color.fromRGBO(tc.r, tc.g, tc.b, 1);
  }

  return textColor;
}

String? getRoleIconUrl(Member member, List<Role> roles) {
  Role? topRole;
  Role? topEmojiRole;
  String? roleIconUrl;
  Color textColor = Colors.white;

  for (PartialRole partialRole in member.roles) {
    Role? role = roles.firstWhereOrNull((role) => partialRole.id == role.id);
    if (role == null) {
      continue;
    }
    topRole ??= role;

    if (role.icon != null) {
      topEmojiRole ??= role;
      if (topEmojiRole.position < role.position) {
        topEmojiRole = role;
      }
    }

    if (topRole.position < role.position) {
      topRole = role;
    }

    var tc = topRole.color;
    roleIconUrl = topEmojiRole?.icon?.url.toString();
    if (tc.value != 0) textColor = Color.fromRGBO(tc.r, tc.g, tc.b, 1);
  }

  return roleIconUrl;
}
