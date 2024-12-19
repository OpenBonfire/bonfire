import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

class GuildFolder with ToStringHelper {
  final String? name;
  final Snowflake? id;
  final int? color;
  final List<Snowflake> guildIds;

  const GuildFolder({
    this.name,
    this.color,
    this.id,
    required this.guildIds,
  });
}
