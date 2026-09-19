// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_guildIdsStream)
final _guildIdsStreamProvider = _GuildIdsStreamProvider._();

final class _GuildIdsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Snowflake>>,
          List<Snowflake>,
          Stream<List<Snowflake>>
        >
    with $FutureModifier<List<Snowflake>>, $StreamProvider<List<Snowflake>> {
  _GuildIdsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_guildIdsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_guildIdsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Snowflake>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Snowflake>> create(Ref ref) {
    return _guildIdsStream(ref);
  }
}

String _$_guildIdsStreamHash() => r'b1f21cbebecf3453c95e541ffb7bb5ce9f0112b0';

@ProviderFor(guildIds)
final guildIdsProvider = GuildIdsProvider._();

final class GuildIdsProvider
    extends
        $FunctionalProvider<List<Snowflake>, List<Snowflake>, List<Snowflake>>
    with $Provider<List<Snowflake>> {
  GuildIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guildIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guildIdsHash();

  @$internal
  @override
  $ProviderElement<List<Snowflake>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Snowflake> create(Ref ref) {
    return guildIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Snowflake> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Snowflake>>(value),
    );
  }
}

String _$guildIdsHash() => r'740e8be0196b027aa311944dd2d29d01de00786e';

@ProviderFor(_guildStream)
final _guildStreamProvider = _GuildStreamFamily._();

final class _GuildStreamProvider
    extends $FunctionalProvider<AsyncValue<Guild?>, Guild?, Stream<Guild?>>
    with $FutureModifier<Guild?>, $StreamProvider<Guild?> {
  _GuildStreamProvider._({
    required _GuildStreamFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'_guildStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_guildStreamHash();

  @override
  String toString() {
    return r'_guildStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Guild?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Guild?> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return _guildStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _GuildStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_guildStreamHash() => r'a03873b053315c67afcd7239e0e71acb534849f8';

final class _GuildStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Guild?>, Snowflake> {
  _GuildStreamFamily._()
    : super(
        retry: null,
        name: r'_guildStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _GuildStreamProvider call(Snowflake id) =>
      _GuildStreamProvider._(argument: id, from: this);

  @override
  String toString() => r'_guildStreamProvider';
}

@ProviderFor(guild)
final guildProvider = GuildFamily._();

final class GuildProvider extends $FunctionalProvider<Guild?, Guild?, Guild?>
    with $Provider<Guild?> {
  GuildProvider._({
    required GuildFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'guildProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guildHash();

  @override
  String toString() {
    return r'guildProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Guild?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Guild? create(Ref ref) {
    final argument = this.argument as Snowflake;
    return guild(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Guild? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Guild?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GuildProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guildHash() => r'd75bc7f43e8dcb5a2510ef706a51eb4251ed3a72';

final class GuildFamily extends $Family
    with $FunctionalFamilyOverride<Guild?, Snowflake> {
  GuildFamily._()
    : super(
        retry: null,
        name: r'guildProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GuildProvider call(Snowflake id) => GuildProvider._(argument: id, from: this);

  @override
  String toString() => r'guildProvider';
}

@ProviderFor(_guildFoldersStream)
final _guildFoldersStreamProvider = _GuildFoldersStreamProvider._();

final class _GuildFoldersStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GuildFolder>>,
          List<GuildFolder>,
          Stream<List<GuildFolder>>
        >
    with
        $FutureModifier<List<GuildFolder>>,
        $StreamProvider<List<GuildFolder>> {
  _GuildFoldersStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_guildFoldersStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_guildFoldersStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<GuildFolder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GuildFolder>> create(Ref ref) {
    return _guildFoldersStream(ref);
  }
}

String _$_guildFoldersStreamHash() =>
    r'2e53bb55b87ce519af44410376a32afacb2bc482';

@ProviderFor(guildFolders)
final guildFoldersProvider = GuildFoldersProvider._();

final class GuildFoldersProvider
    extends
        $FunctionalProvider<
          List<GuildFolder>,
          List<GuildFolder>,
          List<GuildFolder>
        >
    with $Provider<List<GuildFolder>> {
  GuildFoldersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guildFoldersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guildFoldersHash();

  @$internal
  @override
  $ProviderElement<List<GuildFolder>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<GuildFolder> create(Ref ref) {
    return guildFolders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<GuildFolder> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<GuildFolder>>(value),
    );
  }
}

String _$guildFoldersHash() => r'55d302dbed6d6a5b3aac320fdf2b03906405b15e';

@ProviderFor(_guildChannelsStream)
final _guildChannelsStreamProvider = _GuildChannelsStreamFamily._();

final class _GuildChannelsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Channel>>,
          List<Channel>,
          Stream<List<Channel>>
        >
    with $FutureModifier<List<Channel>>, $StreamProvider<List<Channel>> {
  _GuildChannelsStreamProvider._({
    required _GuildChannelsStreamFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'_guildChannelsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_guildChannelsStreamHash();

  @override
  String toString() {
    return r'_guildChannelsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Channel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Channel>> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return _guildChannelsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _GuildChannelsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_guildChannelsStreamHash() =>
    r'bbdef2d491d801985fb6b268657929fc9df81727';

final class _GuildChannelsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Channel>>, Snowflake> {
  _GuildChannelsStreamFamily._()
    : super(
        retry: null,
        name: r'_guildChannelsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _GuildChannelsStreamProvider call(Snowflake id) =>
      _GuildChannelsStreamProvider._(argument: id, from: this);

  @override
  String toString() => r'_guildChannelsStreamProvider';
}

@ProviderFor(guildChannels)
final guildChannelsProvider = GuildChannelsFamily._();

final class GuildChannelsProvider
    extends $FunctionalProvider<List<Channel>?, List<Channel>?, List<Channel>?>
    with $Provider<List<Channel>?> {
  GuildChannelsProvider._({
    required GuildChannelsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'guildChannelsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guildChannelsHash();

  @override
  String toString() {
    return r'guildChannelsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Channel>?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Channel>? create(Ref ref) {
    final argument = this.argument as Snowflake;
    return guildChannels(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Channel>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Channel>?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GuildChannelsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guildChannelsHash() => r'fbd6c50241a709a767cf31d9f218b23a6a28344e';

final class GuildChannelsFamily extends $Family
    with $FunctionalFamilyOverride<List<Channel>?, Snowflake> {
  GuildChannelsFamily._()
    : super(
        retry: null,
        name: r'guildChannelsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GuildChannelsProvider call(Snowflake id) =>
      GuildChannelsProvider._(argument: id, from: this);

  @override
  String toString() => r'guildChannelsProvider';
}

@ProviderFor(_channelStream)
final _channelStreamProvider = _ChannelStreamFamily._();

final class _ChannelStreamProvider
    extends
        $FunctionalProvider<AsyncValue<Channel?>, Channel?, Stream<Channel?>>
    with $FutureModifier<Channel?>, $StreamProvider<Channel?> {
  _ChannelStreamProvider._({
    required _ChannelStreamFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'_channelStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_channelStreamHash();

  @override
  String toString() {
    return r'_channelStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Channel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Channel?> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return _channelStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _ChannelStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_channelStreamHash() => r'a81622d8ed0de57fffc939b707b3d753ec39a76b';

final class _ChannelStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Channel?>, Snowflake> {
  _ChannelStreamFamily._()
    : super(
        retry: null,
        name: r'_channelStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _ChannelStreamProvider call(Snowflake id) =>
      _ChannelStreamProvider._(argument: id, from: this);

  @override
  String toString() => r'_channelStreamProvider';
}

@ProviderFor(channel)
final channelProvider = ChannelFamily._();

final class ChannelProvider
    extends $FunctionalProvider<Channel?, Channel?, Channel?>
    with $Provider<Channel?> {
  ChannelProvider._({
    required ChannelFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'channelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelHash();

  @override
  String toString() {
    return r'channelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Channel?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Channel? create(Ref ref) {
    final argument = this.argument as Snowflake;
    return channel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Channel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Channel?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelHash() => r'a6d521772671d6ac0e8d48d7250297bbd6cfcc9c';

final class ChannelFamily extends $Family
    with $FunctionalFamilyOverride<Channel?, Snowflake> {
  ChannelFamily._()
    : super(
        retry: null,
        name: r'channelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChannelProvider call(Snowflake id) =>
      ChannelProvider._(argument: id, from: this);

  @override
  String toString() => r'channelProvider';
}

@ProviderFor(_lastReadMessageIdStream)
final _lastReadMessageIdStreamProvider = _LastReadMessageIdStreamFamily._();

final class _LastReadMessageIdStreamProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, Stream<int?>>
    with $FutureModifier<int?>, $StreamProvider<int?> {
  _LastReadMessageIdStreamProvider._({
    required _LastReadMessageIdStreamFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'_lastReadMessageIdStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_lastReadMessageIdStreamHash();

  @override
  String toString() {
    return r'_lastReadMessageIdStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int?> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return _lastReadMessageIdStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _LastReadMessageIdStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_lastReadMessageIdStreamHash() =>
    r'f1805e38867d7ad7fbc182cf227420b00522e49c';

final class _LastReadMessageIdStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int?>, Snowflake> {
  _LastReadMessageIdStreamFamily._()
    : super(
        retry: null,
        name: r'_lastReadMessageIdStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _LastReadMessageIdStreamProvider call(Snowflake channelId) =>
      _LastReadMessageIdStreamProvider._(argument: channelId, from: this);

  @override
  String toString() => r'_lastReadMessageIdStreamProvider';
}

/// Whether [channelId] has messages the user hasn't read yet. `false` for
/// non-text channels (categories, voice, ...) since they have no read state.

@ProviderFor(channelHasUnreads)
final channelHasUnreadsProvider = ChannelHasUnreadsFamily._();

/// Whether [channelId] has messages the user hasn't read yet. `false` for
/// non-text channels (categories, voice, ...) since they have no read state.

final class ChannelHasUnreadsProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether [channelId] has messages the user hasn't read yet. `false` for
  /// non-text channels (categories, voice, ...) since they have no read state.
  ChannelHasUnreadsProvider._({
    required ChannelHasUnreadsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'channelHasUnreadsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelHasUnreadsHash();

  @override
  String toString() {
    return r'channelHasUnreadsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as Snowflake;
    return channelHasUnreads(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelHasUnreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelHasUnreadsHash() => r'12ed943607399f6d44a17fc6ba449ff876f2c85d';

/// Whether [channelId] has messages the user hasn't read yet. `false` for
/// non-text channels (categories, voice, ...) since they have no read state.

final class ChannelHasUnreadsFamily extends $Family
    with $FunctionalFamilyOverride<bool, Snowflake> {
  ChannelHasUnreadsFamily._()
    : super(
        retry: null,
        name: r'channelHasUnreadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [channelId] has messages the user hasn't read yet. `false` for
  /// non-text channels (categories, voice, ...) since they have no read state.

  ChannelHasUnreadsProvider call(Snowflake channelId) =>
      ChannelHasUnreadsProvider._(argument: channelId, from: this);

  @override
  String toString() => r'channelHasUnreadsProvider';
}

/// Whether any channel in [guildId] has unread messages.

@ProviderFor(guildHasUnreads)
final guildHasUnreadsProvider = GuildHasUnreadsFamily._();

/// Whether any channel in [guildId] has unread messages.

final class GuildHasUnreadsProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether any channel in [guildId] has unread messages.
  GuildHasUnreadsProvider._({
    required GuildHasUnreadsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'guildHasUnreadsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guildHasUnreadsHash();

  @override
  String toString() {
    return r'guildHasUnreadsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as Snowflake;
    return guildHasUnreads(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GuildHasUnreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guildHasUnreadsHash() => r'd23d957369b6c9ec1057779954cdaf98dd85b2fe';

/// Whether any channel in [guildId] has unread messages.

final class GuildHasUnreadsFamily extends $Family
    with $FunctionalFamilyOverride<bool, Snowflake> {
  GuildHasUnreadsFamily._()
    : super(
        retry: null,
        name: r'guildHasUnreadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether any channel in [guildId] has unread messages.

  GuildHasUnreadsProvider call(Snowflake guildId) =>
      GuildHasUnreadsProvider._(argument: guildId, from: this);

  @override
  String toString() => r'guildHasUnreadsProvider';
}

/// Whether any guild in [folder] has unread messages.

@ProviderFor(folderHasUnreads)
final folderHasUnreadsProvider = FolderHasUnreadsFamily._();

/// Whether any guild in [folder] has unread messages.

final class FolderHasUnreadsProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether any guild in [folder] has unread messages.
  FolderHasUnreadsProvider._({
    required FolderHasUnreadsFamily super.from,
    required GuildFolder super.argument,
  }) : super(
         retry: null,
         name: r'folderHasUnreadsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$folderHasUnreadsHash();

  @override
  String toString() {
    return r'folderHasUnreadsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as GuildFolder;
    return folderHasUnreads(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FolderHasUnreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderHasUnreadsHash() => r'8a32ac83f903e6ca50b3d00e85d1aca533f3cc11';

/// Whether any guild in [folder] has unread messages.

final class FolderHasUnreadsFamily extends $Family
    with $FunctionalFamilyOverride<bool, GuildFolder> {
  FolderHasUnreadsFamily._()
    : super(
        retry: null,
        name: r'folderHasUnreadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether any guild in [folder] has unread messages.

  FolderHasUnreadsProvider call(GuildFolder folder) =>
      FolderHasUnreadsProvider._(argument: folder, from: this);

  @override
  String toString() => r'folderHasUnreadsProvider';
}

@ProviderFor(_userStream)
final _userStreamProvider = _UserStreamFamily._();

final class _UserStreamProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  _UserStreamProvider._({
    required _UserStreamFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'_userStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_userStreamHash();

  @override
  String toString() {
    return r'_userStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return _userStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _UserStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_userStreamHash() => r'c3dffb7f71ebac8e28f0196646344849d4f10ec3';

final class _UserStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<User?>, Snowflake> {
  _UserStreamFamily._()
    : super(
        retry: null,
        name: r'_userStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _UserStreamProvider call(Snowflake id) =>
      _UserStreamProvider._(argument: id, from: this);

  @override
  String toString() => r'_userStreamProvider';
}

@ProviderFor(user)
final userProvider = UserFamily._();

final class UserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  UserProvider._({
    required UserFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'userProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userHash();

  @override
  String toString() {
    return r'userProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    final argument = this.argument as Snowflake;
    return user(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userHash() => r'477c4489c7fef334994c81dde5e22bf31b56265b';

final class UserFamily extends $Family
    with $FunctionalFamilyOverride<User?, Snowflake> {
  UserFamily._()
    : super(
        retry: null,
        name: r'userProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserProvider call(Snowflake id) => UserProvider._(argument: id, from: this);

  @override
  String toString() => r'userProvider';
}

@ProviderFor(_channelVoiceStateUserIdsStream)
final _channelVoiceStateUserIdsStreamProvider =
    _ChannelVoiceStateUserIdsStreamFamily._();

final class _ChannelVoiceStateUserIdsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Snowflake>>,
          List<Snowflake>,
          Stream<List<Snowflake>>
        >
    with $FutureModifier<List<Snowflake>>, $StreamProvider<List<Snowflake>> {
  _ChannelVoiceStateUserIdsStreamProvider._({
    required _ChannelVoiceStateUserIdsStreamFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'_channelVoiceStateUserIdsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_channelVoiceStateUserIdsStreamHash();

  @override
  String toString() {
    return r'_channelVoiceStateUserIdsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Snowflake>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Snowflake>> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return _channelVoiceStateUserIdsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _ChannelVoiceStateUserIdsStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_channelVoiceStateUserIdsStreamHash() =>
    r'404ef8a59d4d588982f1651b6ff42775e01a1ea7';

final class _ChannelVoiceStateUserIdsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Snowflake>>, Snowflake> {
  _ChannelVoiceStateUserIdsStreamFamily._()
    : super(
        retry: null,
        name: r'_channelVoiceStateUserIdsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _ChannelVoiceStateUserIdsStreamProvider call(Snowflake channelId) =>
      _ChannelVoiceStateUserIdsStreamProvider._(
        argument: channelId,
        from: this,
      );

  @override
  String toString() => r'_channelVoiceStateUserIdsStreamProvider';
}

/// The ids of the users currently connected to voice channel [channelId].

@ProviderFor(channelVoiceStateUserIds)
final channelVoiceStateUserIdsProvider = ChannelVoiceStateUserIdsFamily._();

/// The ids of the users currently connected to voice channel [channelId].

final class ChannelVoiceStateUserIdsProvider
    extends
        $FunctionalProvider<List<Snowflake>, List<Snowflake>, List<Snowflake>>
    with $Provider<List<Snowflake>> {
  /// The ids of the users currently connected to voice channel [channelId].
  ChannelVoiceStateUserIdsProvider._({
    required ChannelVoiceStateUserIdsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'channelVoiceStateUserIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelVoiceStateUserIdsHash();

  @override
  String toString() {
    return r'channelVoiceStateUserIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Snowflake>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Snowflake> create(Ref ref) {
    final argument = this.argument as Snowflake;
    return channelVoiceStateUserIds(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Snowflake> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Snowflake>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelVoiceStateUserIdsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelVoiceStateUserIdsHash() =>
    r'3e9784f95c2c72b84417acde03ea925d8c862e26';

/// The ids of the users currently connected to voice channel [channelId].

final class ChannelVoiceStateUserIdsFamily extends $Family
    with $FunctionalFamilyOverride<List<Snowflake>, Snowflake> {
  ChannelVoiceStateUserIdsFamily._()
    : super(
        retry: null,
        name: r'channelVoiceStateUserIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The ids of the users currently connected to voice channel [channelId].

  ChannelVoiceStateUserIdsProvider call(Snowflake channelId) =>
      ChannelVoiceStateUserIdsProvider._(argument: channelId, from: this);

  @override
  String toString() => r'channelVoiceStateUserIdsProvider';
}
