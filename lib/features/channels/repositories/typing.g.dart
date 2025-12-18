// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Typing)
const typingProvider = TypingFamily._();

final class TypingProvider
    extends $AsyncNotifierProvider<Typing, List<dynamic>> {
  const TypingProvider._({
    required TypingFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'typingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$typingHash();

  @override
  String toString() {
    return r'typingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Typing create() => Typing();

  @override
  bool operator ==(Object other) {
    return other is TypingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$typingHash() => r'40ea65aa147633284a5048ea8c136460ecd1551d';

final class TypingFamily extends $Family
    with
        $ClassFamilyOverride<
          Typing,
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>,
          Snowflake
        > {
  const TypingFamily._()
    : super(
        retry: null,
        name: r'typingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TypingProvider call(Snowflake channelId) =>
      TypingProvider._(argument: channelId, from: this);

  @override
  String toString() => r'typingProvider';
}

abstract class _$Typing extends $AsyncNotifier<List<dynamic>> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get channelId => _$args;

  FutureOr<List<dynamic>> build(Snowflake channelId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<dynamic>>, List<dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<dynamic>>, List<dynamic>>,
              AsyncValue<List<dynamic>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
