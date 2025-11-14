import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/models/gateway/events/guild.dart';

class ChannelStatusesBuilder extends CreateBuilder<ChannelStatusesEvent> {
  Snowflake? guildId;

  @override
  Map<String, Object?> build() => {
        'guild_id': guildId?.toString(),
      };
}
