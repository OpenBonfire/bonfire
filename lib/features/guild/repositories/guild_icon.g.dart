// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_icon.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(guildIcon)
const guildIconProvider = GuildIconFamily._();

final class GuildIconProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>
        >
    with $FutureModifier<Uint8List?>, $FutureProvider<Uint8List?> {
  const GuildIconProvider._({
    required GuildIconFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'guildIconProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guildIconHash();

  @override
  String toString() {
    return r'guildIconProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List?> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return guildIcon(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GuildIconProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guildIconHash() => r'98eb9f593543e9e4ac96b04f6b40f9bef5750bc4';

final class GuildIconFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List?>, Snowflake> {
  const GuildIconFamily._()
    : super(
        retry: null,
        name: r'guildIconProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GuildIconProvider call(Snowflake guildId) =>
      GuildIconProvider._(argument: guildId, from: this);

  @override
  String toString() => r'guildIconProvider';
}
