import 'package:firebridge/firebridge.dart';

String getChannelName(Channel channel) {
  if (channel is DmChannel) {
    String name = "";
    for (var recipient in channel.recipients) {
      name += "${recipient.globalName ?? recipient.username}, ";
    }

    return name.substring(0, name.length - 2);
  }

  if (channel is GroupDmChannel) {
    String name = "";
    for (var recipient in channel.recipients) {
      name += "${recipient.globalName ?? recipient.username}, ";
    }

    return name.substring(0, name.length - 2);
  }

  return (channel as GuildChannel).name;
}
