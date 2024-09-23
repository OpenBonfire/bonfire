// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_members.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voiceMembersHash() => r'b6194d4089c8de21b13a3c8e435568b1abd9ac04';

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

abstract class _$VoiceMembers
    extends BuildlessAsyncNotifier<List<MapEntry<Snowflake, VoiceState>>?> {
  late final Snowflake guildId;
  late final Snowflake? channelId;

  FutureOr<List<MapEntry<Snowflake, VoiceState>>?> build(
    Snowflake guildId, {
    Snowflake? channelId,
  });
}

/// See also [VoiceMembers].
@ProviderFor(VoiceMembers)
const voiceMembersProvider = VoiceMembersFamily();

/// See also [VoiceMembers].
class VoiceMembersFamily
    extends Family<AsyncValue<List<MapEntry<Snowflake, VoiceState>>?>> {
  /// See also [VoiceMembers].
  const VoiceMembersFamily();

  /// See also [VoiceMembers].
  VoiceMembersProvider call(
    Snowflake guildId, {
    Snowflake? channelId,
  }) {
    return VoiceMembersProvider(
      guildId,
      channelId: channelId,
    );
  }

  @override
  VoiceMembersProvider getProviderOverride(
    covariant VoiceMembersProvider provider,
  ) {
    return call(
      provider.guildId,
      channelId: provider.channelId,
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
  String? get name => r'voiceMembersProvider';
}

/// See also [VoiceMembers].
class VoiceMembersProvider extends AsyncNotifierProviderImpl<VoiceMembers,
    List<MapEntry<Snowflake, VoiceState>>?> {
  /// See also [VoiceMembers].
  VoiceMembersProvider(
    Snowflake guildId, {
    Snowflake? channelId,
  }) : this._internal(
          () => VoiceMembers()
            ..guildId = guildId
            ..channelId = channelId,
          from: voiceMembersProvider,
          name: r'voiceMembersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$voiceMembersHash,
          dependencies: VoiceMembersFamily._dependencies,
          allTransitiveDependencies:
              VoiceMembersFamily._allTransitiveDependencies,
          guildId: guildId,
          channelId: channelId,
        );

  VoiceMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guildId,
    required this.channelId,
  }) : super.internal();

  final Snowflake guildId;
  final Snowflake? channelId;

  @override
  FutureOr<List<MapEntry<Snowflake, VoiceState>>?> runNotifierBuild(
    covariant VoiceMembers notifier,
  ) {
    return notifier.build(
      guildId,
      channelId: channelId,
    );
  }

  @override
  Override overrideWith(VoiceMembers Function() create) {
    return ProviderOverride(
      origin: this,
      override: VoiceMembersProvider._internal(
        () => create()
          ..guildId = guildId
          ..channelId = channelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guildId: guildId,
        channelId: channelId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<VoiceMembers,
      List<MapEntry<Snowflake, VoiceState>>?> createElement() {
    return _VoiceMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VoiceMembersProvider &&
        other.guildId == guildId &&
        other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VoiceMembersRef
    on AsyncNotifierProviderRef<List<MapEntry<Snowflake, VoiceState>>?> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;

  /// The parameter `channelId` of this provider.
  Snowflake? get channelId;
}

class _VoiceMembersProviderElement extends AsyncNotifierProviderElement<
    VoiceMembers, List<MapEntry<Snowflake, VoiceState>>?> with VoiceMembersRef {
  _VoiceMembersProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as VoiceMembersProvider).guildId;
  @override
  Snowflake? get channelId => (origin as VoiceMembersProvider).channelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
