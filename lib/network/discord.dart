import 'package:discord_api/discord_api.dart';

// https://discord.com/oauth2/authorize?client_id=1228043349550956644&permissions=0&response_type=code&redirect_uri=https%3A%2F%2Fwww.google.com%2F&scope=identify+guilds+gdm.join+rpc.voice.read+rpc.video.write+rpc.activities.write+messages.read+applications.commands+activities.read+voice+applications.commands.permissions.update+dm_channels.read+applications.store.update+activities.write+applications.builds.upload+bot+rpc.screenshare.read+rpc.voice.write+guilds.join+email+rpc+connections+rpc.notifications.read+guilds.members.read+rpc.video.read+rpc.screenshare.write+applications.builds.read+webhook.incoming+relationships.read+applications.entitlements+role_connections.write'

final discordClient = DiscordClient(
  clientId: "1228043349550956644",
  clientSecret: "InfdjO7ME9nVPBaTeotKe9CmUePx6d1m",
  redirectUri: "https://www.google.com/",
  discordHttpClient: DiscordDioProvider(
      clientId: "1228043349550956644",
      clientSecret: "InfdjO7ME9nVPBaTeotKe9CmUePx6d1m"),
);
