import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/utils/to_string_helper/to_string_helper.dart';

class ProfileEffect with ToStringHelper {
  final Snowflake id;
  final DateTime? expiresAt;

  ProfileEffect({
    required this.id,
    this.expiresAt,
  });
}

class ProfileEffectPosition with ToStringHelper {
  final int x;
  final int y;

  ProfileEffectPosition({required this.x, required this.y});
}

class ProfileEffectAnimation with ToStringHelper {
  final String src;
  final bool loop;
  final int height;
  final int width;
  final int duration;
  final int start;
  final int loopDelay;
  final ProfileEffectPosition position;
  final int zIndex;

  ProfileEffectAnimation({
    required this.src,
    required this.loop,
    required this.height,
    required this.width,
    required this.duration,
    required this.start,
    required this.loopDelay,
    required this.position,
    required this.zIndex,
  });
}

class ProfileEffectConfig with ToStringHelper {
  final Snowflake id;
  final int type;
  final String skuId;
  final String title;
  final String description;
  final String accessibilityLabel;
  final int animationType;
  final String thumnbnailPreviewSrc;
  final String reducedMotionSrc;
  final List<ProfileEffectAnimation> effects;

  ProfileEffectConfig({
    required this.id,
    required this.type,
    required this.skuId,
    required this.title,
    required this.description,
    required this.accessibilityLabel,
    required this.animationType,
    required this.thumnbnailPreviewSrc,
    required this.reducedMotionSrc,
    required this.effects,
  });
}
