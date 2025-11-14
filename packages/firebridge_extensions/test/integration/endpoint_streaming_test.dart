import 'dart:io';

import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:test/test.dart';

void main() {
  final testToken = Platform.environment['TEST_TOKEN']!;
  final testChannelId = Snowflake.parse(Platform.environment['TEST_TEXT_CHANNEL']!);

  group('streaming endpoint pagination', () {
    late NyxxRest client;
    late PartialTextChannel channel;
    setUp(() async {
      client = await Nyxx.connectRest(testToken);
      channel = client.channels[testChannelId] as PartialTextChannel;
    });
    tearDown(() => client.close());

    test('returns items from endpoint', () {
      final stream = channel.messages.stream().take(10);
      expect(stream, emits(anything));
    });

    test('respects before', () async {
      final messages = await channel.messages.fetchMany();
      final middle = messages[messages.length ~/ 2].id;
      // Force multiple pages to be fetched.
      final streamedMessages = await channel.messages.stream(before: middle, pageSize: 10).take(50).toList();

      expect(streamedMessages, isNotEmpty);
      for (final message in streamedMessages) {
        expect(message.id.isBefore(middle), isTrue);
      }
    });

    test('respects after', () async {
      final messages = await channel.messages.fetchMany();
      final middle = messages[messages.length ~/ 2].id;
      // Force multiple pages to be fetched.
      final streamedMessages = await channel.messages.stream(after: middle, pageSize: 10).take(50).toList();

      expect(streamedMessages, isNotEmpty);
      for (final message in streamedMessages) {
        expect(message.id.isAfter(middle), isTrue);
      }
    });

    test('returns items in order', () async {
      final oldestFirstMessages = await channel.messages.stream(order: StreamOrder.oldestFirst).take(50).toList();
      for (int i = 0; i < oldestFirstMessages.length - 1; i++) {
        expect(oldestFirstMessages[i].id.isBefore(oldestFirstMessages[i + 1].id), isTrue);
      }

      final mostRecentFirstMessages = await channel.messages.stream(order: StreamOrder.mostRecentFirst).take(50).toList();
      for (int i = 0; i < mostRecentFirstMessages.length - 1; i++) {
        expect(mostRecentFirstMessages[i].id.isAfter(mostRecentFirstMessages[i + 1].id), isTrue);
      }
    });
  });
}
