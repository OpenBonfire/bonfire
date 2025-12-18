// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A riverpod provider that handles authentication with Discord.

@ProviderFor(Auth)
const authProvider = AuthProvider._();

/// A riverpod provider that handles authentication with Discord.
final class AuthProvider extends $NotifierProvider<Auth, AuthResponse?> {
  /// A riverpod provider that handles authentication with Discord.
  const AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthResponse? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthResponse?>(value),
    );
  }
}

String _$authHash() => r'e649e36edd9eb11ff00dff55cd1a71ded0098b3d';

/// A riverpod provider that handles authentication with Discord.

abstract class _$Auth extends $Notifier<AuthResponse?> {
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
