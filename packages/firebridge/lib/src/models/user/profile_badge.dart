import 'package:firebridge/src/utils/to_string_helper/to_string_helper.dart';

class ProfileBadge with ToStringHelper {
  final String id;
  final String description;
  final String iconHash;
  final Uri? link;

  ProfileBadge({
    required this.id,
    required this.description,
    required this.iconHash,
    this.link,
  });
}
