// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$presenceControllerHash() =>
    r'c61e47940b2eafc16eb039bac4425f7f24544379';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$PresenceController
    extends BuildlessNotifier<PresenceUpdateEvent?> {
  late final Snowflake userId;

  PresenceUpdateEvent? build(
    Snowflake userId,
  );
}

/// See also [PresenceController].
@ProviderFor(PresenceController)
const presenceControllerProvider = PresenceControllerFamily();

/// See also [PresenceController].
class PresenceControllerFamily extends Family<PresenceUpdateEvent?> {
  /// See also [PresenceController].
  const PresenceControllerFamily();

  /// See also [PresenceController].
  PresenceControllerProvider call(
    Snowflake userId,
  ) {
    return PresenceControllerProvider(
      userId,
    );
  }

  @override
  PresenceControllerProvider getProviderOverride(
    covariant PresenceControllerProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'presenceControllerProvider';
}

/// See also [PresenceController].
class PresenceControllerProvider
    extends NotifierProviderImpl<PresenceController, PresenceUpdateEvent?> {
  /// See also [PresenceController].
  PresenceControllerProvider(
    Snowflake userId,
  ) : this._internal(
          () => PresenceController()..userId = userId,
          from: presenceControllerProvider,
          name: r'presenceControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$presenceControllerHash,
          dependencies: PresenceControllerFamily._dependencies,
          allTransitiveDependencies:
              PresenceControllerFamily._allTransitiveDependencies,
          userId: userId,
        );

  PresenceControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final Snowflake userId;

  @override
  PresenceUpdateEvent? runNotifierBuild(
    covariant PresenceController notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(PresenceController Function() create) {
    return ProviderOverride(
      origin: this,
      override: PresenceControllerProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  NotifierProviderElement<PresenceController, PresenceUpdateEvent?>
      createElement() {
    return _PresenceControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PresenceControllerProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PresenceControllerRef on NotifierProviderRef<PresenceUpdateEvent?> {
  /// The parameter `userId` of this provider.
  Snowflake get userId;
}

class _PresenceControllerProviderElement
    extends NotifierProviderElement<PresenceController, PresenceUpdateEvent?>
    with PresenceControllerRef {
  _PresenceControllerProviderElement(super.provider);

  @override
  Snowflake get userId => (origin as PresenceControllerProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
