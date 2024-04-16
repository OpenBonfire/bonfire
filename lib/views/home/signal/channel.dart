import 'package:nyxx/nyxx.dart';
import 'package:signals/signals.dart';

Signal<UserGuild?> guildSignal = Signal(null);
Signal<GuildChannel?> channelSignal = Signal(null);