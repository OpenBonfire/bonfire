import 'package:firebridge/src/utils/to_string_helper/to_string_helper.dart';

class GuildMemberRange with ToStringHelper {
  final int lowerMemberBound;
  final int upperMemberBound;

  GuildMemberRange({
    required this.lowerMemberBound,
    required this.upperMemberBound,
  });
}
