import "dart:io";

import "package:firebridge/firebridge.dart";
import "package:firebridge_extensions/firebridge_extensions.dart";

void main() async {
  final client = await Nyxx.connectGateway(
    Platform.environment['TOKEN']!,
    GatewayIntents.guildMessages | GatewayIntents.messageContent,
    options: GatewayClientOptions(plugins: [logging, cliIntegration, pagination]),
  );

  // Get an emoji by its unicode character...
  final heartEmoji = client.getTextEmoji('❤️');

  // ...or list all available emojis
  final allEmojis = await client.getTextEmojis();
  print('There are currently ${allEmojis.length} emojis!');

  // Get information about a text emoji!
  final heartEmojiInformation = await heartEmoji.getDefinition();
  print('The primary name of ${heartEmojiInformation.surrogates} is ${heartEmojiInformation.primaryName}');

  // Sanitizing content makes it safe to send to Discord without triggering any mentions
  client.onMessageCreate.listen((event) async {
    if (event.message.content.startsWith('!sanitize')) {
      event.message.channel.sendMessage(MessageBuilder(
        content: 'Sanitized content: ${await sanitizeContent(event.message.content, channel: event.message.channel)}',
      ));
    }
  });

  // Pagination allows for long segments of text to be sent as one chunk.
  const loreumIpsum = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Donec massa sapien faucibus et. Et
malesuada fames ac turpis egestas maecenas pharetra convallis. Vulputate eu
scelerisque felis imperdiet proin fermentum leo. Amet risus nullam eget felis
eget nunc lobortis mattis aliquam. Id leo in vitae turpis. Adipiscing elit
pellentesque habitant morbi tristique. Adipiscing commodo elit at imperdiet
dui. Ridiculus mus mauris vitae ultricies leo. Sapien pellentesque habitant
morbi tristique senectus. Mauris pellentesque pulvinar pellentesque habitant.
Mus mauris vitae ultricies leo integer malesuada. Sit amet est placerat in
egestas erat. Id leo in vitae turpis massa sed elementum tempus egestas.
Posuere sollicitudin aliquam ultrices sagittis orci a scelerisque purus.

Sagittis orci a scelerisque purus semper eget. Nisl purus in mollis nunc.
Curabitur vitae nunc sed velit. At lectus urna duis convallis convallis tellus
id. Risus nec feugiat in fermentum posuere urna nec. At elementum eu facilisis
sed odio morbi quis. Est ante in nibh mauris. Dictumst quisque sagittis purus
sit amet volutpat consequat. Quis imperdiet massa tincidunt nunc pulvinar
sapien. Viverra tellus in hac habitasse platea dictumst vestibulum. Eu
consequat ac felis donec et. Mauris a diam maecenas sed enim ut sem. Placerat
in egestas erat imperdiet sed. Orci eu lobortis elementum nibh tellus molestie
nunc non blandit. Rutrum tellus pellentesque eu tincidunt tortor aliquam.
Imperdiet proin fermentum leo vel orci porta non. Ullamcorper velit sed
ullamcorper morbi tincidunt ornare.
''';

  client.onMessageCreate.listen((event) async {
    if (event.message.content.startsWith('!pages')) {
      await event.message.channel.sendMessage(await pagination.split(
        loreumIpsum,
        // Split into chunks 100 characters long.
        maxLength: 100,
      ));
    }
  });

  // ...and more!
}
