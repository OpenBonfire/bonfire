// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Get user by id

@ProviderFor(getUserFromId)
const getUserFromIdProvider = GetUserFromIdFamily._();

/// Get user by id

final class GetUserFromIdProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, FutureOr<User?>>
    with $FutureModifier<User?>, $FutureProvider<User?> {
  /// Get user by id
  const GetUserFromIdProvider._({
    required GetUserFromIdFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'getUserFromIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getUserFromIdHash();

  @override
  String toString() {
    return r'getUserFromIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<User?> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return getUserFromId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetUserFromIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getUserFromIdHash() => r'b9f710953c3cadec6e35fdda3d2edd185e7d4f5a';

/// Get user by id

final class GetUserFromIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<User?>, Snowflake> {
  const GetUserFromIdFamily._()
    : super(
        retry: null,
        name: r'getUserFromIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Get user by id

  GetUserFromIdProvider call(Snowflake userId) =>
      GetUserFromIdProvider._(argument: userId, from: this);

  @override
  String toString() => r'getUserFromIdProvider';
}
