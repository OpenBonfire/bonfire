// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ready.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReadyController)
const readyControllerProvider = ReadyControllerProvider._();

final class ReadyControllerProvider
    extends $NotifierProvider<ReadyController, bool> {
  const ReadyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readyControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readyControllerHash();

  @$internal
  @override
  ReadyController create() => ReadyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$readyControllerHash() => r'0406dc674f63b19b460235328f165b7f6be4e59e';

abstract class _$ReadyController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
