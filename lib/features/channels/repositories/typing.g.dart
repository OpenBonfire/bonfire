// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$typingHash() => r'ac9aa8bf6eb8dbcaed2baa58d7e313157b4eecd4';

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

abstract class _$Typing
    extends BuildlessAutoDisposeAsyncNotifier<List<dynamic>> {
  late final Snowflake channelId;

  FutureOr<List<dynamic>> build(
    Snowflake channelId,
  );
}

/// See also [Typing].
@ProviderFor(Typing)
const typingProvider = TypingFamily();

/// See also [Typing].
class TypingFamily extends Family<AsyncValue<List<dynamic>>> {
  /// See also [Typing].
  const TypingFamily();

  /// See also [Typing].
  TypingProvider call(
    Snowflake channelId,
  ) {
    return TypingProvider(
      channelId,
    );
  }

  @override
  TypingProvider getProviderOverride(
    covariant TypingProvider provider,
  ) {
    return call(
      provider.channelId,
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
  String? get name => r'typingProvider';
}

/// See also [Typing].
class TypingProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Typing, List<dynamic>> {
  /// See also [Typing].
  TypingProvider(
    Snowflake channelId,
  ) : this._internal(
          () => Typing()..channelId = channelId,
          from: typingProvider,
          name: r'typingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$typingHash,
          dependencies: TypingFamily._dependencies,
          allTransitiveDependencies: TypingFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  TypingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.channelId,
  }) : super.internal();

  final Snowflake channelId;

  @override
  FutureOr<List<dynamic>> runNotifierBuild(
    covariant Typing notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(Typing Function() create) {
    return ProviderOverride(
      origin: this,
      override: TypingProvider._internal(
        () => create()..channelId = channelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        channelId: channelId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<Typing, List<dynamic>>
      createElement() {
    return _TypingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TypingProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TypingRef on AutoDisposeAsyncNotifierProviderRef<List<dynamic>> {
  /// The parameter `channelId` of this provider.
  Snowflake get channelId;
}

class _TypingProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Typing, List<dynamic>>
    with TypingRef {
  _TypingProviderElement(super.provider);

  @override
  Snowflake get channelId => (origin as TypingProvider).channelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
