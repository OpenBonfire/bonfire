// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_guildIdsStream)
const _guildIdsStreamProvider = _GuildIdsStreamProvider._();

final class _GuildIdsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Snowflake>>,
          List<Snowflake>,
          Stream<List<Snowflake>>
        >
    with $FutureModifier<List<Snowflake>>, $StreamProvider<List<Snowflake>> {
  const _GuildIdsStreamProvider._()
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
const guildIdsProvider = GuildIdsProvider._();

final class GuildIdsProvider
    extends
        $FunctionalProvider<List<Snowflake>, List<Snowflake>, List<Snowflake>>
    with $Provider<List<Snowflake>> {
  const GuildIdsProvider._()
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
const _guildStreamProvider = _GuildStreamFamily._();

final class _GuildStreamProvider
    extends $FunctionalProvider<AsyncValue<Guild?>, Guild?, Stream<Guild?>>
    with $FutureModifier<Guild?>, $StreamProvider<Guild?> {
  const _GuildStreamProvider._({
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
  const _GuildStreamFamily._()
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
const guildProvider = GuildFamily._();

final class GuildProvider extends $FunctionalProvider<Guild?, Guild?, Guild?>
    with $Provider<Guild?> {
  const GuildProvider._({
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
  const GuildFamily._()
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
const _guildFoldersStreamProvider = _GuildFoldersStreamProvider._();

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
  const _GuildFoldersStreamProvider._()
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
const guildFoldersProvider = GuildFoldersProvider._();

final class GuildFoldersProvider
    extends
        $FunctionalProvider<
          List<GuildFolder>,
          List<GuildFolder>,
          List<GuildFolder>
        >
    with $Provider<List<GuildFolder>> {
  const GuildFoldersProvider._()
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
const _guildChannelsStreamProvider = _GuildChannelsStreamFamily._();

final class _GuildChannelsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Channel>>,
          List<Channel>,
          Stream<List<Channel>>
        >
    with $FutureModifier<List<Channel>>, $StreamProvider<List<Channel>> {
  const _GuildChannelsStreamProvider._({
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
  const _GuildChannelsStreamFamily._()
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
const guildChannelsProvider = GuildChannelsFamily._();

final class GuildChannelsProvider
    extends $FunctionalProvider<List<Channel>?, List<Channel>?, List<Channel>?>
    with $Provider<List<Channel>?> {
  const GuildChannelsProvider._({
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
  const GuildChannelsFamily._()
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
const _channelStreamProvider = _ChannelStreamFamily._();

final class _ChannelStreamProvider
    extends
        $FunctionalProvider<AsyncValue<Channel?>, Channel?, Stream<Channel?>>
    with $FutureModifier<Channel?>, $StreamProvider<Channel?> {
  const _ChannelStreamProvider._({
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
  const _ChannelStreamFamily._()
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
const channelProvider = ChannelFamily._();

final class ChannelProvider
    extends $FunctionalProvider<Channel?, Channel?, Channel?>
    with $Provider<Channel?> {
  const ChannelProvider._({
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
  const ChannelFamily._()
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
