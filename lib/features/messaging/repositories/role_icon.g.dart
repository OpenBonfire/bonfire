// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_icon.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(roleIcon)
const roleIconProvider = RoleIconFamily._();

final class RoleIconProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>
        >
    with $FutureModifier<Uint8List?>, $FutureProvider<Uint8List?> {
  const RoleIconProvider._({
    required RoleIconFamily super.from,
    required (Snowflake, Snowflake) super.argument,
  }) : super(
         retry: null,
         name: r'roleIconProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$roleIconHash();

  @override
  String toString() {
    return r'roleIconProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List?> create(Ref ref) {
    final argument = this.argument as (Snowflake, Snowflake);
    return roleIcon(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RoleIconProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$roleIconHash() => r'a79e59f58fce4b58e786b94e4dd3610e09fd443b';

final class RoleIconFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Uint8List?>,
          (Snowflake, Snowflake)
        > {
  const RoleIconFamily._()
    : super(
        retry: null,
        name: r'roleIconProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  RoleIconProvider call(Snowflake guildId, Snowflake authorId) =>
      RoleIconProvider._(argument: (guildId, authorId), from: this);

  @override
  String toString() => r'roleIconProvider';
}

@ProviderFor(roleColor)
const roleColorProvider = RoleColorFamily._();

final class RoleColorProvider
    extends $FunctionalProvider<AsyncValue<Color>, Color, FutureOr<Color>>
    with $FutureModifier<Color>, $FutureProvider<Color> {
  const RoleColorProvider._({
    required RoleColorFamily super.from,
    required (Snowflake, Snowflake) super.argument,
  }) : super(
         retry: null,
         name: r'roleColorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$roleColorHash();

  @override
  String toString() {
    return r'roleColorProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Color> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Color> create(Ref ref) {
    final argument = this.argument as (Snowflake, Snowflake);
    return roleColor(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RoleColorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$roleColorHash() => r'80e5f2e0a1324b363d53a829f6bb440676cf70ff';

final class RoleColorFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Color>, (Snowflake, Snowflake)> {
  const RoleColorFamily._()
    : super(
        retry: null,
        name: r'roleColorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RoleColorProvider call(Snowflake guildId, Snowflake authorId) =>
      RoleColorProvider._(argument: (guildId, authorId), from: this);

  @override
  String toString() => r'roleColorProvider';
}
