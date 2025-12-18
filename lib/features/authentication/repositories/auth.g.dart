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
    extends $NotifierProvider<ClientController, AuthResponse?> {
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
  Override overrideWithValue(AuthResponse? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthResponse?>(value),
    );
  }
}

String _$clientControllerHash() => r'37b4d4b9c0e5c939b03530d611506e748bf06a2f';

/// A riverpod provider that handles authentication with Discord.

abstract class _$ClientController extends $Notifier<AuthResponse?> {
  AuthResponse? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AuthResponse?, AuthResponse?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthResponse?, AuthResponse?>,
              AuthResponse?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
