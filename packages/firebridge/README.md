# Firebridge

[![documentation](https://img.shields.io/badge/Documentation-nyxx-yellow.svg)](https://pub.dev/documentation/nyxx/latest/)

An experimental package to use Discord with user accounts, built off of Nyxx.

**Note**: Using this with your user account is against TOS! Proceed at your own risk.

To get started using nyxx, follow the Nyxx [getting started guide](https://nyxx.l7ssha.xyz/docs/tutorials/writing_your_first_bot) to write your first bot.

If you're already familiar with Discord's API, here's a quick example to get you started:
```dart
import 'package:firebridge/firebridge.dart';

void main() async {
  final client = await Nyxx.connectGateway('<TOKEN>', GatewayIntents.allUnprivileged);

  final botUser = await client.users.fetchCurrentUser();

  client.onMessageCreate.listen((event) async {
    if (event.mentions.contains(botUser)) {
      await event.message.channel.sendMessage(MessageBuilder(
        content: 'You mentioned me!',
        replyId: event.message.id,
      ));
    }
  });
}
```

## Other nyxx packages

- [firebridge_extensions](https://github.com/OpenBonfire/firebridge_extensions): Fork of [nyxx_extensions](https://github.com/nyxx-discord/nyxx_extensions) various extensions on top of firebridge (such as parsing permissions).

## More examples

- More examples can be found in our GitHub repository [here](https://github.com/nyxx-discord/nyxx/tree/main/example).
- [Running on Dart](https://github.com/nyxx-discord/running_on_dart) is a complete example of a bot written with nyxx.

## Additional documentation & help

The API documentation for the latest stable version can be found on [pub](https://pub.dev/documentation/nyxx).

### [Docs and wiki](https://nyxx.l7ssha.xyz)
Tutorials and wiki articles are hosted here, as well as API documentation for development versions from GitHub.

### [Discord API docs](https://discord.dev/)
Discord's API documentation details what nyxx implements & provides more detailed explanations of certain topics.

### [Pub.dev docs](https://pub.dev/documentation/nyxx)
The dartdocs page will always have the documentation for the latest release.

## Contributing to Firebridge

Read the [contributing document](https://github.com/OpenBonfire/firebridge/blob/dev/CONTRIBUTING.md)

## Credits 

- Thanks to [Hackzzila's](https://github.com/Hackzzila) for [nyx](https://github.com/Hackzzila/nyx), the original project nyxx was forked from, as well as [Nyxx](https://github.com/nyxx-discord/nyxx), the project that firebridge is forked from.
