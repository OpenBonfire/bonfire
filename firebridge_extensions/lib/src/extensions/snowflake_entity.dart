import 'package:firebridge/firebridge.dart';

/// Extensions on [SnowflakeEntity]s.
extension SnowflakeEntityExtensions<T extends SnowflakeEntity<T>>
    on SnowflakeEntity<T> {
  /// [get] this entity, but return `null` if an exception is thrown (most
  /// commonly indicating the entity does not exist).
  Future<T?> getOrNull() async {
    try {
      return await get();
    } on Exception {
      return null;
    }
  }
}

/// Extensions on [ManagedSnowflakeEntity]s.
extension ManagedSnowflakeEntityExtensions<T extends ManagedSnowflakeEntity<T>>
    on ManagedSnowflakeEntity<T> {
  /// Return this entity from the manager's cache, or `null` if this entity is not cached.
  T? getFromCache() => manager.cache[id];
}
