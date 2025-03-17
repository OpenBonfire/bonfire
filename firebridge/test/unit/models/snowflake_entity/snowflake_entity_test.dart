import 'package:mocktail/mocktail.dart';
import 'package:firebridge/firebridge.dart';
import 'package:test/test.dart';

class PartialMockSnowflakeEntity
    extends WritableSnowflakeEntity<MockSnowflakeEntity> {
  @override
  final MockSnowflakeEntityManager manager = MockSnowflakeEntityManager();

  /// @nodoc
  PartialMockSnowflakeEntity({required super.id});
}

class MockSnowflakeEntity extends PartialMockSnowflakeEntity {
  /// @nodoc
  MockSnowflakeEntity({required super.id});
}

class MockSnowflakeEntityManager
    with Mock
    implements Manager<MockSnowflakeEntity> {}

void main() {
  group('SnowflakeEntity', () {
    test('equality', () {
      final entity1 = MockSnowflakeEntity(id: Snowflake(BigInt.one), json: {});
      final entity2 = MockSnowflakeEntity(id: Snowflake(BigInt.one), json: {});

      expect(entity1, equals(entity2));
      expect(entity1.hashCode, equals(entity2.hashCode));
    });

    test('equality with partial entities', () {
      final entity = MockSnowflakeEntity(id: Snowflake(BigInt.one), json: {});
      final partial =
          PartialMockSnowflakeEntity(id: Snowflake(BigInt.one), json: {});

      expect(entity, equals(partial));
      expect(partial, equals(entity));
      expect(entity.hashCode, equals(partial.hashCode));
    });

    test('equality between partial entities', () {
      final partial1 =
          PartialMockSnowflakeEntity(id: Snowflake(BigInt.one), json: {});
      final partial2 =
          PartialMockSnowflakeEntity(id: Snowflake(BigInt.one), json: {});

      expect(partial1, equals(partial2));
      expect(partial1.hashCode, equals(partial2.hashCode));
    });
  });
}
