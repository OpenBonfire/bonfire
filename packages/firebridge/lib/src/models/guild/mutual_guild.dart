import 'package:firebridge/src/utils/to_string_helper/to_string_helper.dart';

class MutualGuild with ToStringHelper {
  final int id;
  final String? nick;

  MutualGuild({
    required this.id,
    required this.nick,
  });
}
