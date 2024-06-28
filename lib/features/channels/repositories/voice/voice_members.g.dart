// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_members.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voiceMembersHash() => r'8e2604549a48c79d14a1b05f886505a98a39cdb2';

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

abstract class _$VoiceMembers extends BuildlessAutoDisposeAsyncNotifier<void> {
  late final Guild guild;
  late final Channel channel;

  FutureOr<void> build(
    Guild guild,
    Channel channel,
  );
}

/// See also [VoiceMembers].
@ProviderFor(VoiceMembers)
const voiceMembersProvider = VoiceMembersFamily();

/// See also [VoiceMembers].
class VoiceMembersFamily extends Family<AsyncValue<void>> {
  /// See also [VoiceMembers].
  const VoiceMembersFamily();

  /// See also [VoiceMembers].
  VoiceMembersProvider call(
    Guild guild,
    Channel channel,
  ) {
    return VoiceMembersProvider(
      guild,
      channel,
    );
  }

  @override
  VoiceMembersProvider getProviderOverride(
    covariant VoiceMembersProvider provider,
  ) {
    return call(
      provider.guild,
      provider.channel,
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
class VoiceMembersProvider
    extends AutoDisposeAsyncNotifierProviderImpl<VoiceMembers, void> {
  /// See also [VoiceMembers].
  VoiceMembersProvider(
    Guild guild,
    Channel channel,
  ) : this._internal(
          () => VoiceMembers()
            ..guild = guild
            ..channel = channel,
          from: voiceMembersProvider,
          name: r'voiceMembersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$voiceMembersHash,
          dependencies: VoiceMembersFamily._dependencies,
          allTransitiveDependencies:
              VoiceMembersFamily._allTransitiveDependencies,
          guild: guild,
          channel: channel,
        );

  VoiceMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guild,
    required this.channel,
  }) : super.internal();

  final Guild guild;
  final Channel channel;

  @override
  FutureOr<void> runNotifierBuild(
    covariant VoiceMembers notifier,
  ) {
    return notifier.build(
      guild,
      channel,
    );
  }

  @override
  Override overrideWith(VoiceMembers Function() create) {
    return ProviderOverride(
      origin: this,
      override: VoiceMembersProvider._internal(
        () => create()
          ..guild = guild
          ..channel = channel,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guild: guild,
        channel: channel,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<VoiceMembers, void> createElement() {
    return _VoiceMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VoiceMembersProvider &&
        other.guild == guild &&
        other.channel == channel;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guild.hashCode);
    hash = _SystemHash.combine(hash, channel.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VoiceMembersRef on AutoDisposeAsyncNotifierProviderRef<void> {
  /// The parameter `guild` of this provider.
  Guild get guild;

  /// The parameter `channel` of this provider.
  Channel get channel;
}

class _VoiceMembersProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<VoiceMembers, void>
    with VoiceMembersRef {
  _VoiceMembersProviderElement(super.provider);

  @override
  Guild get guild => (origin as VoiceMembersProvider).guild;
  @override
  Channel get channel => (origin as VoiceMembersProvider).channel;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
