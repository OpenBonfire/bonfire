// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'self_user.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Get the current user

@ProviderFor(SelfUser)
const selfUserProvider = SelfUserProvider._();

/// Get the current user
final class SelfUserProvider extends $AsyncNotifierProvider<SelfUser, User?> {
  /// Get the current user
  const SelfUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selfUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selfUserHash();

  @$internal
  @override
  SelfUser create() => SelfUser();
}

String _$selfUserHash() => r'741a7ae9309b20e8c3b3572590f22a3adf54d960';

/// Get the current user

abstract class _$SelfUser extends $AsyncNotifier<User?> {
  FutureOr<User?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<User?>, User?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<User?>, User?>,
              AsyncValue<User?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
