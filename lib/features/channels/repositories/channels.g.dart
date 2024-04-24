// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channels.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$channelsHash() => r'da88c7bc83be2e5f7ad5e21d8ef148f429a3feef';

/// A riverpod provider that fetches the channels for the current guild.
///
/// Copied from [Channels].
@ProviderFor(Channels)
final channelsProvider =
    AutoDisposeAsyncNotifierProvider<Channels, List<BonfireChannel>>.internal(
  Channels.new,
  name: r'channelsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$channelsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Channels = AutoDisposeAsyncNotifier<List<BonfireChannel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
