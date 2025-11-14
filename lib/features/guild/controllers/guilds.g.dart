// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guilds.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guildsControllerHash() => r'1fbe9d3a66dc3ee4e40d6b022d82ee10194e21e3';

/// Fetches the current guild from [guildid].
///
/// Copied from [GuildsController].
@ProviderFor(GuildsController)
final guildsControllerProvider =
    NotifierProvider<GuildsController, List<Guild>?>.internal(
  GuildsController.new,
  name: r'guildsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$guildsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GuildsController = Notifier<List<Guild>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
