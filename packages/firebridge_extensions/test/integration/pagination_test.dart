import 'dart:io';

import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:test/test.dart';

void main() {
  final testToken = Platform.environment['TEST_TOKEN']!;
  final testTextChannel = Platform.environment['TEST_TEXT_CHANNEL'];

  test(
    'Pagination',
    skip: testTextChannel == null ? 'No text channel provided' : false,
    () async {
      final pagination = Pagination(PaginationOptions());

      final client = await Nyxx.connectGateway(
        testToken,
        GatewayIntents.guildMessages,
        options: GatewayClientOptions(plugins: [pagination]),
      );

      final channel = client.channels[Snowflake.parse(testTextChannel!)] as PartialTextChannel;

      late Message message;

      await expectLater(
        channel
            .sendMessage(await pagination.builders([
              MessageBuilder(content: 'Test page 1'),
              MessageBuilder(content: 'Test page 2'),
              MessageBuilder(content: 'Test page 3'),
            ]))
            .then((value) => message = value),
        completes,
      );

      await message.delete();

      await client.close();
    },
  );
}
