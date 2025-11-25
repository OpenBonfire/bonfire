// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PresenceController)
const presenceControllerProvider = PresenceControllerFamily._();

final class PresenceControllerProvider
    extends $NotifierProvider<PresenceController, PresenceUpdateEvent?> {
  const PresenceControllerProvider._({
    required PresenceControllerFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'presenceControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$presenceControllerHash();

  @override
  String toString() {
    return r'presenceControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PresenceController create() => PresenceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PresenceUpdateEvent? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PresenceUpdateEvent?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PresenceControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$presenceControllerHash() =>
    r'c61e47940b2eafc16eb039bac4425f7f24544379';

final class PresenceControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PresenceController,
          PresenceUpdateEvent?,
          PresenceUpdateEvent?,
          PresenceUpdateEvent?,
          Snowflake
        > {
  const PresenceControllerFamily._()
    : super(
        retry: null,
        name: r'presenceControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PresenceControllerProvider call(Snowflake userId) =>
      PresenceControllerProvider._(argument: userId, from: this);

  @override
  String toString() => r'presenceControllerProvider';
}

abstract class _$PresenceController extends $Notifier<PresenceUpdateEvent?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get userId => _$args;

  PresenceUpdateEvent? build(Snowflake userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<PresenceUpdateEvent?, PresenceUpdateEvent?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PresenceUpdateEvent?, PresenceUpdateEvent?>,
              PresenceUpdateEvent?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
