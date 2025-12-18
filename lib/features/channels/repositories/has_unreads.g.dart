// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'has_unreads.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HasUnreads)
const hasUnreadsProvider = HasUnreadsFamily._();

final class HasUnreadsProvider
    extends $AsyncNotifierProvider<HasUnreads, bool> {
  const HasUnreadsProvider._({
    required HasUnreadsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'hasUnreadsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hasUnreadsHash();

  @override
  String toString() {
    return r'hasUnreadsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HasUnreads create() => HasUnreads();

  @override
  bool operator ==(Object other) {
    return other is HasUnreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasUnreadsHash() => r'c2f9e70c097d9516a591fff9c8a3733962410e44';

final class HasUnreadsFamily extends $Family
    with
        $ClassFamilyOverride<
          HasUnreads,
          AsyncValue<bool>,
          bool,
          FutureOr<bool>,
          Snowflake
        > {
  const HasUnreadsFamily._()
    : super(
        retry: null,
        name: r'hasUnreadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  HasUnreadsProvider call(Snowflake channelId) =>
      HasUnreadsProvider._(argument: channelId, from: this);

  @override
  String toString() => r'hasUnreadsProvider';
}

abstract class _$HasUnreads extends $AsyncNotifier<bool> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get channelId => _$args;

  FutureOr<bool> build(Snowflake channelId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
