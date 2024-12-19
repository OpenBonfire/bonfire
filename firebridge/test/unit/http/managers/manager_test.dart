import 'package:mocktail/mocktail.dart';
import 'package:firebridge/firebridge.dart';
import 'package:test/test.dart';

import '../../../mocks/client.dart';

class TestFetchException implements Exception {}

class MockManager extends Manager<MockSnowflakeEntity> with Fake {
  MockManager(super.config, super.client)
      : super(identifier: 'MOCK_IDENTIFIER');

  @override
  Future<MockSnowflakeEntity> fetch(Snowflake id) => throw TestFetchException();
}

class MockSnowflakeEntity extends WritableSnowflakeEntity<MockSnowflakeEntity>
    with Fake {
  MockSnowflakeEntity({
    required super.id,
    required super.json,
  });
}

void main() {
  group('Manager', () {
    test('get only calls API when entity is not cached', () {
      final manager = MockManager(CacheConfig(), MockNyxx());

      manager.cache[Snowflake.zero] =
          MockSnowflakeEntity(id: Snowflake.zero, json: {});

      expect(() => manager.get(Snowflake.zero), returnsNormally);
    });

    test('calls API when entity is not cached', () {
      final manager = MockManager(CacheConfig(), MockNyxx());

      expect(() => manager.get(Snowflake.zero),
          throwsA(isA<TestFetchException>()));
    });
  });
}
