import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class MemberRoleHelper {
  final Member member;
  final List<Role> roles;

  MemberRoleHelper(this.member, this.roles);

  Role? getTopRole() {
    Role? topRole;

    for (Snowflake partialRole in member.roles) {
      Role? role = roles.firstWhereOrNull((role) => partialRole == role.id);
      if (role == null) {
        continue;
      }

      if (role.color.value == 0) {
        continue;
      }

      if (topRole == null || role.position > topRole.position) {
        topRole = role;
      }
    }

    return topRole;
  }

  Role? getTopEmojiRole() {
    // Role? topEmojiRole;

    // for (Snowflake partialRole in member.roles) {
    //   Role? role = roles.firstWhereOrNull((role) => partialRole.id == role.id);
    //   if (role == null || role.icon == null) {
    //     continue;
    //   }

    //   if (topEmojiRole == null || role.position > topEmojiRole.position) {
    //     topEmojiRole = role;
    //   }
    // }
    // return topEmojiRole;
  }

  Color getRoleColor() {
    Role? topRole = getTopRole();
    if (topRole != null) {
      return Color.fromRGBO(
        topRole.color.r,
        topRole.color.g,
        topRole.color.b,
        1,
      );
    }
    return Colors.white;
  }

  String? getRoleIconUrl() {
    // Role? topEmojiRole = getTopEmojiRole();
    // return topEmojiRole?.icon?.url.toString();
  }
}

Color getRoleColor(Member member, List<Role> roles) {
  final helper = MemberRoleHelper(member, roles);
  return helper.getRoleColor();
}

String? getRoleIconUrl(Member member, List<Role> roles) {
  final helper = MemberRoleHelper(member, roles);
  return helper.getRoleIconUrl();
}
