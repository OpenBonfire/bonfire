import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/models/user/profile_effect.dart';
import 'package:firebridge/src/utils/to_string_helper/to_string_helper.dart';

class ProfileMetadata with ToStringHelper {
  final Snowflake? guildId;
  final String pronouns;
  final String? bio;
  final String? bannerHash;
  final int? accentColor;
// final List<List<int>>? themeColors;
  final List<dynamic>? themeColors;
  final Snowflake? popoutAnimationParticleType;
  final Emoji? emoji;
  final ProfileEffect? profileEffect;

  ProfileMetadata({
    this.guildId,
    required this.pronouns,
    this.bio,
    this.bannerHash,
    this.accentColor,
    this.themeColors,
    this.popoutAnimationParticleType,
    this.emoji,
    this.profileEffect,
  });
}
