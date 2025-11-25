// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the current roles from [guildId].

@ProviderFor(RolesController)
const rolesControllerProvider = RolesControllerFamily._();

/// Fetches the current roles from [guildId].
final class RolesControllerProvider
    extends $NotifierProvider<RolesController, List<Snowflake>?> {
  /// Fetches the current roles from [guildId].
  const RolesControllerProvider._({
    required RolesControllerFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'rolesControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rolesControllerHash();

  @override
  String toString() {
    return r'rolesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RolesController create() => RolesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Snowflake>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Snowflake>?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RolesControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rolesControllerHash() => r'0785eb2bff764f0cba882b5a0c8303ae39ea6e07';

/// Fetches the current roles from [guildId].

final class RolesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RolesController,
          List<Snowflake>?,
          List<Snowflake>?,
          List<Snowflake>?,
          Snowflake
        > {
  const RolesControllerFamily._()
    : super(
        retry: null,
        name: r'rolesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Fetches the current roles from [guildId].

  RolesControllerProvider call(Snowflake guildId) =>
      RolesControllerProvider._(argument: guildId, from: this);

  @override
  String toString() => r'rolesControllerProvider';
}

/// Fetches the current roles from [guildId].

abstract class _$RolesController extends $Notifier<List<Snowflake>?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get guildId => _$args;

  List<Snowflake>? build(Snowflake guildId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<List<Snowflake>?, List<Snowflake>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Snowflake>?, List<Snowflake>?>,
              List<Snowflake>?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
