// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authHash() => r'f1f1b3498cdd37c9182254b974ee5cd7fb1ebeac';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [auth].
@ProviderFor(auth)
const authProvider = AuthFamily();

/// See also [auth].
class AuthFamily extends Family<AsyncValue<AuthResponse>> {
  /// See also [auth].
  const AuthFamily();

  /// See also [auth].
  AuthProvider call(
    LoginAuthenticator authenticator,
  ) {
    return AuthProvider(
      authenticator,
    );
  }

  @override
  AuthProvider getProviderOverride(
    covariant AuthProvider provider,
  ) {
    return call(
      provider.authenticator,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'authProvider';
}

/// See also [auth].
class AuthProvider extends AutoDisposeFutureProvider<AuthResponse> {
  /// See also [auth].
  AuthProvider(
    LoginAuthenticator authenticator,
  ) : this._internal(
          (ref) => auth(
            ref as AuthRef,
            authenticator,
          ),
          from: authProvider,
          name: r'authProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product') ? null : _$authHash,
          dependencies: AuthFamily._dependencies,
          allTransitiveDependencies: AuthFamily._allTransitiveDependencies,
          authenticator: authenticator,
        );

  AuthProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.authenticator,
  }) : super.internal();

  final LoginAuthenticator authenticator;

  @override
  Override overrideWith(
    FutureOr<AuthResponse> Function(AuthRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AuthProvider._internal(
        (ref) => create(ref as AuthRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        authenticator: authenticator,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AuthResponse> createElement() {
    return _AuthProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AuthProvider && other.authenticator == authenticator;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, authenticator.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AuthRef on AutoDisposeFutureProviderRef<AuthResponse> {
  /// The parameter `authenticator` of this provider.
  LoginAuthenticator get authenticator;
}

class _AuthProviderElement
    extends AutoDisposeFutureProviderElement<AuthResponse> with AuthRef {
  _AuthProviderElement(super.provider);

  @override
  LoginAuthenticator get authenticator =>
      (origin as AuthProvider).authenticator;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
