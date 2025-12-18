// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(guildBannerUrl)
const guildBannerUrlProvider = GuildBannerUrlFamily._();

final class GuildBannerUrlProvider
    extends $FunctionalProvider<AsyncValue<Uri?>, Uri?, FutureOr<Uri?>>
    with $FutureModifier<Uri?>, $FutureProvider<Uri?> {
  const GuildBannerUrlProvider._({
    required GuildBannerUrlFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'guildBannerUrlProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guildBannerUrlHash();

  @override
  String toString() {
    return r'guildBannerUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uri?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uri?> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return guildBannerUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GuildBannerUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guildBannerUrlHash() => r'aeb8cb8cb63663b183191bc71f3b69fb915ca7c2';

final class GuildBannerUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uri?>, Snowflake> {
  const GuildBannerUrlFamily._()
    : super(
        retry: null,
        name: r'guildBannerUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GuildBannerUrlProvider call(Snowflake guildId) =>
      GuildBannerUrlProvider._(argument: guildId, from: this);

  @override
  String toString() => r'guildBannerUrlProvider';
}
