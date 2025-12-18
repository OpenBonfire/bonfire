// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getMember)
const getMemberProvider = GetMemberFamily._();

final class GetMemberProvider
    extends $FunctionalProvider<AsyncValue<Member?>, Member?, FutureOr<Member?>>
    with $FutureModifier<Member?>, $FutureProvider<Member?> {
  const GetMemberProvider._({
    required GetMemberFamily super.from,
    required (Snowflake, Snowflake) super.argument,
  }) : super(
         retry: null,
         name: r'getMemberProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getMemberHash();

  @override
  String toString() {
    return r'getMemberProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Member?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Member?> create(Ref ref) {
    final argument = this.argument as (Snowflake, Snowflake);
    return getMember(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is GetMemberProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getMemberHash() => r'13c92cb5c0a2fa0e5d2b9cea6f163eecbc8c0ffe';

final class GetMemberFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Member?>, (Snowflake, Snowflake)> {
  const GetMemberFamily._()
    : super(
        retry: null,
        name: r'getMemberProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GetMemberProvider call(Snowflake guildId, Snowflake memberId) =>
      GetMemberProvider._(argument: (guildId, memberId), from: this);

  @override
  String toString() => r'getMemberProvider';
}

@ProviderFor(getSelfMember)
const getSelfMemberProvider = GetSelfMemberFamily._();

final class GetSelfMemberProvider
    extends $FunctionalProvider<AsyncValue<Member?>, Member?, FutureOr<Member?>>
    with $FutureModifier<Member?>, $FutureProvider<Member?> {
  const GetSelfMemberProvider._({
    required GetSelfMemberFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'getSelfMemberProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getSelfMemberHash();

  @override
  String toString() {
    return r'getSelfMemberProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Member?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Member?> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return getSelfMember(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetSelfMemberProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getSelfMemberHash() => r'7d0297319c1184768d92fae212463c4f536c91de';

final class GetSelfMemberFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Member?>, Snowflake> {
  const GetSelfMemberFamily._()
    : super(
        retry: null,
        name: r'getSelfMemberProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GetSelfMemberProvider call(Snowflake guildId) =>
      GetSelfMemberProvider._(argument: guildId, from: this);

  @override
  String toString() => r'getSelfMemberProvider';
}

@ProviderFor(getGuildRoles)
const getGuildRolesProvider = GetGuildRolesFamily._();

final class GetGuildRolesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Role>?>,
          List<Role>?,
          FutureOr<List<Role>?>
        >
    with $FutureModifier<List<Role>?>, $FutureProvider<List<Role>?> {
  const GetGuildRolesProvider._({
    required GetGuildRolesFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'getGuildRolesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getGuildRolesHash();

  @override
  String toString() {
    return r'getGuildRolesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Role>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Role>?> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return getGuildRoles(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetGuildRolesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getGuildRolesHash() => r'63f288fa97a88070e5b3de22afab229c60c87757';

final class GetGuildRolesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Role>?>, Snowflake> {
  const GetGuildRolesFamily._()
    : super(
        retry: null,
        name: r'getGuildRolesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GetGuildRolesProvider call(Snowflake guildId) =>
      GetGuildRolesProvider._(argument: guildId, from: this);

  @override
  String toString() => r'getGuildRolesProvider';
}

@ProviderFor(getRole)
const getRoleProvider = GetRoleFamily._();

final class GetRoleProvider
    extends $FunctionalProvider<AsyncValue<Role?>, Role?, FutureOr<Role?>>
    with $FutureModifier<Role?>, $FutureProvider<Role?> {
  const GetRoleProvider._({
    required GetRoleFamily super.from,
    required (Snowflake, Snowflake) super.argument,
  }) : super(
         retry: null,
         name: r'getRoleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getRoleHash();

  @override
  String toString() {
    return r'getRoleProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Role?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Role?> create(Ref ref) {
    final argument = this.argument as (Snowflake, Snowflake);
    return getRole(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is GetRoleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getRoleHash() => r'd2e1a8a6cdd5822577aefe58d897276120f84b15';

final class GetRoleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Role?>, (Snowflake, Snowflake)> {
  const GetRoleFamily._()
    : super(
        retry: null,
        name: r'getRoleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetRoleProvider call(Snowflake guildId, Snowflake roleId) =>
      GetRoleProvider._(argument: (guildId, roleId), from: this);

  @override
  String toString() => r'getRoleProvider';
}
