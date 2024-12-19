import 'dart:async';

import 'package:firebridge/src/builders/builder.dart';
import 'package:firebridge/src/http/managers/manager.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/utils/to_string_helper/to_string_helper.dart';

/// The base class for all entities in the API identified by a [Snowflake].
abstract class SnowflakeEntity<T extends SnowflakeEntity<T>>
    with ToStringHelper {
  /// The id of this entity.
  final Snowflake id;
  final Map<String, Object?> json;

  /// Create a new [SnowflakeEntity].
  /// @nodoc
  SnowflakeEntity({required this.id, required this.json});

  /// If this entity exists in the manager's cache, return the cached instance. Otherwise, [fetch]
  /// this entity and return it.
  Future<T> get();

  /// Fetch this entity from the API.
  Future<T> fetch();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SnowflakeEntity<T> && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String defaultToString() => '$T($id)';
}

/// The base class for all [SnowflakeEntity]'s that have a dedicated [ReadOnlyManager].
abstract class ManagedSnowflakeEntity<T extends ManagedSnowflakeEntity<T>>
    extends SnowflakeEntity<T> {
  /// The manager for this entity.
  ReadOnlyManager<T> get manager;

  /// Create a new [ManagedSnowflakeEntity];
  /// @nodoc
  ManagedSnowflakeEntity({required super.id, required super.json});

  @override
  Future<T> get() => manager.get(id);

  @override
  Future<T> fetch() => manager.fetch(id);
}

/// The base class for all [SnowflakeEntity]'s that have a dedicated [Manager].
abstract class WritableSnowflakeEntity<T extends WritableSnowflakeEntity<T>>
    extends ManagedSnowflakeEntity<T> {
  @override
  Manager<T> get manager;

  /// Create a new [WritableSnowflakeEntity].
  /// @nodoc
  WritableSnowflakeEntity({required super.id, required super.json});

  /// Update this entity using the provided builder and return the updated entity.
  Future<T> update(covariant UpdateBuilder<T> builder) =>
      manager.update(id, builder);

  /// Delete this entity.
  Future<void> delete() => manager.delete(id);
}
