// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Gets the role from [roleId].

@ProviderFor(RoleController)
const roleControllerProvider = RoleControllerFamily._();

/// Gets the role from [roleId].
final class RoleControllerProvider
    extends $NotifierProvider<RoleController, Role?> {
  /// Gets the role from [roleId].
  const RoleControllerProvider._({
    required RoleControllerFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'roleControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$roleControllerHash();

  @override
  String toString() {
    return r'roleControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RoleController create() => RoleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Role? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Role?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RoleControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$roleControllerHash() => r'b0278c3a95ca2575c14b52ffb212ab10504ec7c7';

/// Gets the role from [roleId].

final class RoleControllerFamily extends $Family
    with $ClassFamilyOverride<RoleController, Role?, Role?, Role?, Snowflake> {
  const RoleControllerFamily._()
    : super(
        retry: null,
        name: r'roleControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Gets the role from [roleId].

  RoleControllerProvider call(Snowflake roleId) =>
      RoleControllerProvider._(argument: roleId, from: this);

  @override
  String toString() => r'roleControllerProvider';
}

/// Gets the role from [roleId].

abstract class _$RoleController extends $Notifier<Role?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get roleId => _$args;

  Role? build(Snowflake roleId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<Role?, Role?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Role?, Role?>,
              Role?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
