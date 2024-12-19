import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

class CustomStatus with ToStringHelper {
  final String? text;
  final DateTime? expiresAt;
  final String? emojiName;
  final String? emojiId;

  const CustomStatus({
    this.text,
    this.expiresAt,
    this.emojiName,
    this.emojiId,
  });
}
