// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authenticateHash() => r'805df451341ffa675eea9bcbe43d909da4c79eaa';

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

/// See also [authenticate].
@ProviderFor(authenticate)
const authenticateProvider = AuthenticateFamily();

/// See also [authenticate].
class AuthenticateFamily extends Family<AsyncValue<NyxxGateway>> {
  /// See also [authenticate].
  const AuthenticateFamily();

  /// See also [authenticate].
  AuthenticateProvider call(
    String token,
  ) {
    return AuthenticateProvider(
      token,
    );
  }

  @override
  AuthenticateProvider getProviderOverride(
    covariant AuthenticateProvider provider,
  ) {
    return call(
      provider.token,
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
  String? get name => r'authenticateProvider';
}

/// See also [authenticate].
class AuthenticateProvider extends AutoDisposeFutureProvider<NyxxGateway> {
  /// See also [authenticate].
  AuthenticateProvider(
    String token,
  ) : this._internal(
          (ref) => authenticate(
            ref as AuthenticateRef,
            token,
          ),
          from: authenticateProvider,
          name: r'authenticateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$authenticateHash,
          dependencies: AuthenticateFamily._dependencies,
          allTransitiveDependencies:
              AuthenticateFamily._allTransitiveDependencies,
          token: token,
        );

  AuthenticateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.token,
  }) : super.internal();

  final String token;

  @override
  Override overrideWith(
    FutureOr<NyxxGateway> Function(AuthenticateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AuthenticateProvider._internal(
        (ref) => create(ref as AuthenticateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        token: token,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<NyxxGateway> createElement() {
    return _AuthenticateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AuthenticateProvider && other.token == token;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, token.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AuthenticateRef on AutoDisposeFutureProviderRef<NyxxGateway> {
  /// The parameter `token` of this provider.
  String get token;
}

class _AuthenticateProviderElement
    extends AutoDisposeFutureProviderElement<NyxxGateway> with AuthenticateRef {
  _AuthenticateProviderElement(super.provider);

  @override
  String get token => (origin as AuthenticateProvider).token;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
