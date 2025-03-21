import 'package:firebridge/src/models/application.dart';
import 'package:firebridge/src/models/guild/member.dart';
import 'package:firebridge/src/models/guild/mutual_guild.dart';
import 'package:firebridge/src/models/user/application_role_connection.dart';
import 'package:firebridge/src/models/user/connection.dart';
import 'package:firebridge/src/models/user/profile_badge.dart';
import 'package:firebridge/src/models/user/profile_metadata.dart';
import 'package:firebridge/src/models/user/user.dart';
import 'package:firebridge/src/utils/to_string_helper/to_string_helper.dart';

/// User profile requested by the client when clicking on a member card in the official client.
///
/// External references:
/// * Unofficial Discord API Reference: https://docs.discord.sex/resources/user#get-user-profile
class UserProfile with ToStringHelper {
  final Application? application;
  final User user;
  final ProfileMetadata userProfile;
  final List<ProfileBadge> badges;
  final Member? guildMember;
  final ProfileMetadata? guildMemberProfile;
  final List<ProfileBadge> guildBadges;
  final String? legacyUsername;
  final List<MutualGuild>? mutualGuilds;
  final List<PartialUser>? mutualFriends;
  final num? mutualFriendsCount;
  final List<Connection>? connections;
  final List<ApplicationRoleConnection>? applicationRoleConnections;
  final num? premiumType;
  final DateTime? premiumSince;
  final DateTime? premiumGuildSince;

  UserProfile({
    this.application,
    required this.user,
    required this.userProfile,
    required this.badges,
    this.guildMember,
    this.guildMemberProfile,
    required this.guildBadges,
    this.legacyUsername,
    this.mutualGuilds,
    this.mutualFriends,
    this.mutualFriendsCount,
    this.connections,
    this.applicationRoleConnections,
    this.premiumType,
    this.premiumSince,
    this.premiumGuildSince,
  });
}
