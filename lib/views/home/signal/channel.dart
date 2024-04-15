import 'package:nyxx/nyxx.dart';
import 'package:signals/signals.dart';

Signal<UserGuild?> guildSignal = Signal(null);



/*
I could use signals to indicate what guild we're in,
but this really sounds like it would be much better
handled using navigation

Ehhh, I'm not sure. I think I'll just use signals.
*/
