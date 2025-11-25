// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for calculating permissions for a channel

@ProviderFor(ChannelPermissions)
const channelPermissionsProvider = ChannelPermissionsFamily._();

/// Provider for calculating permissions for a channel
final class ChannelPermissionsProvider
    extends $AsyncNotifierProvider<ChannelPermissions, Permissions?> {
  /// Provider for calculating permissions for a channel
  const ChannelPermissionsProvider._({
    required ChannelPermissionsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'channelPermissionsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelPermissionsHash();

  @override
  String toString() {
    return r'channelPermissionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChannelPermissions create() => ChannelPermissions();

  @override
  bool operator ==(Object other) {
    return other is ChannelPermissionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelPermissionsHash() =>
    r'ab65ba280e705f2edce1f71dfbd7dc9d1a9edf29';

/// Provider for calculating permissions for a channel

final class ChannelPermissionsFamily extends $Family
    with
        $ClassFamilyOverride<
          ChannelPermissions,
          AsyncValue<Permissions?>,
          Permissions?,
          FutureOr<Permissions?>,
          Snowflake
        > {
  const ChannelPermissionsFamily._()
    : super(
        retry: null,
        name: r'channelPermissionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Provider for calculating permissions for a channel

  ChannelPermissionsProvider call(Snowflake channelId) =>
      ChannelPermissionsProvider._(argument: channelId, from: this);

  @override
  String toString() => r'channelPermissionsProvider';
}

/// Provider for calculating permissions for a channel

abstract class _$ChannelPermissions extends $AsyncNotifier<Permissions?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get channelId => _$args;

  FutureOr<Permissions?> build(Snowflake channelId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<Permissions?>, Permissions?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Permissions?>, Permissions?>,
              AsyncValue<Permissions?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
