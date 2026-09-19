// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single, app-wide Drift database instance. This is the source of truth
/// for cached entities - kept alive for the lifetime of the app so watch
/// queries can be shared across every screen without reopening the db.

@ProviderFor(appDatabase)
const appDatabaseProvider = AppDatabaseProvider._();

/// The single, app-wide Drift database instance. This is the source of truth
/// for cached entities - kept alive for the lifetime of the app so watch
/// queries can be shared across every screen without reopening the db.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The single, app-wide Drift database instance. This is the source of truth
  /// for cached entities - kept alive for the lifetime of the app so watch
  /// queries can be shared across every screen without reopening the db.
  const AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';
