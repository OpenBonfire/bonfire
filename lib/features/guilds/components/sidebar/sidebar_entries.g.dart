// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_entries.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The ordered, deduplicated list of sidebar rows: guilds in a folder are
/// collapsed into a single [GuildSidebarFolderEntry] (at the position of the
/// first of their guilds), every other guild becomes its own
/// [GuildSidebarGuildEntry], all in [guildIdsProvider] order.

@ProviderFor(guildSidebarEntries)
const guildSidebarEntriesProvider = GuildSidebarEntriesProvider._();

/// The ordered, deduplicated list of sidebar rows: guilds in a folder are
/// collapsed into a single [GuildSidebarFolderEntry] (at the position of the
/// first of their guilds), every other guild becomes its own
/// [GuildSidebarGuildEntry], all in [guildIdsProvider] order.

final class GuildSidebarEntriesProvider
    extends
        $FunctionalProvider<
          List<GuildSidebarEntry>,
          List<GuildSidebarEntry>,
          List<GuildSidebarEntry>
        >
    with $Provider<List<GuildSidebarEntry>> {
  /// The ordered, deduplicated list of sidebar rows: guilds in a folder are
  /// collapsed into a single [GuildSidebarFolderEntry] (at the position of the
  /// first of their guilds), every other guild becomes its own
  /// [GuildSidebarGuildEntry], all in [guildIdsProvider] order.
  const GuildSidebarEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guildSidebarEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guildSidebarEntriesHash();

  @$internal
  @override
  $ProviderElement<List<GuildSidebarEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<GuildSidebarEntry> create(Ref ref) {
    return guildSidebarEntries(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<GuildSidebarEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<GuildSidebarEntry>>(value),
    );
  }
}

String _$guildSidebarEntriesHash() =>
    r'6d4c503b6c3d9c37a3ce97e3713ba5e9014e8710';
