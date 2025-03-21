import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/utils/to_string_helper/to_string_helper.dart';

class ProfileEffect with ToStringHelper {
  final Snowflake id;
  final DateTime expiresAt;

  ProfileEffect({
    required this.id,
    required this.expiresAt,
  });
}
