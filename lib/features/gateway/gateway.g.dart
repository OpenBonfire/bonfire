// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gateway.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GatewayController)
const gatewayControllerProvider = GatewayControllerProvider._();

final class GatewayControllerProvider
    extends $NotifierProvider<GatewayController, void> {
  const GatewayControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gatewayControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gatewayControllerHash();

  @$internal
  @override
  GatewayController create() => GatewayController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$gatewayControllerHash() => r'ddabb1a1349eec6ad519e05bdc5a4c60f2b214fe';

abstract class _$GatewayController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
