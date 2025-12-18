// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A riverpod provider that handles authentication with Discord.

@ProviderFor(ClientController)
const clientControllerProvider = ClientControllerProvider._();

/// A riverpod provider that handles authentication with Discord.
final class ClientControllerProvider
    extends $NotifierProvider<ClientController, FirebridgeGateway?> {
  /// A riverpod provider that handles authentication with Discord.
  const ClientControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientControllerHash();

  @$internal
  @override
  ClientController create() => ClientController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebridgeGateway? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebridgeGateway?>(value),
    );
  }
}

String _$clientControllerHash() => r'bc11d7be89c0adfc58d23b5112a8477866d00f54';

/// A riverpod provider that handles authentication with Discord.

abstract class _$ClientController extends $Notifier<FirebridgeGateway?> {
  FirebridgeGateway? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FirebridgeGateway?, FirebridgeGateway?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FirebridgeGateway?, FirebridgeGateway?>,
              FirebridgeGateway?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
