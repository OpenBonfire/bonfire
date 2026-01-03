// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'entity_store.dart';

class EntityStateMapper extends ClassMapperBase<EntityState> {
  EntityStateMapper._();

  static EntityStateMapper? _instance;
  static EntityStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EntityStateMapper._());
      SnowflakeMapper.ensureInitialized();
      GuildMapper.ensureInitialized();
      ChannelMapper.ensureInitialized();
      GuildFolderMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'EntityState';

  static Map<Snowflake, Guild> _$guilds(EntityState v) => v.guilds;
  static const Field<EntityState, Map<Snowflake, Guild>> _f$guilds = Field(
    'guilds',
    _$guilds,
    opt: true,
    def: const {},
  );
  static Map<Snowflake, List<Channel>> _$guildChannels(EntityState v) =>
      v.guildChannels;
  static const Field<EntityState, Map<Snowflake, List<Channel>>>
  _f$guildChannels = Field(
    'guildChannels',
    _$guildChannels,
    opt: true,
    def: const {},
  );
  static List<Snowflake> _$guildIds(EntityState v) => v.guildIds;
  static const Field<EntityState, List<Snowflake>> _f$guildIds = Field(
    'guildIds',
    _$guildIds,
    opt: true,
    def: const [],
  );
  static List<GuildFolder> _$guildFolders(EntityState v) => v.guildFolders;
  static const Field<EntityState, List<GuildFolder>> _f$guildFolders = Field(
    'guildFolders',
    _$guildFolders,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<EntityState> fields = const {
    #guilds: _f$guilds,
    #guildChannels: _f$guildChannels,
    #guildIds: _f$guildIds,
    #guildFolders: _f$guildFolders,
  };

  static EntityState _instantiate(DecodingData data) {
    return EntityState(
      guilds: data.dec(_f$guilds),
      guildChannels: data.dec(_f$guildChannels),
      guildIds: data.dec(_f$guildIds),
      guildFolders: data.dec(_f$guildFolders),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static EntityState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EntityState>(map);
  }

  static EntityState fromJson(String json) {
    return ensureInitialized().decodeJson<EntityState>(json);
  }
}

mixin EntityStateMappable {
  String toJson() {
    return EntityStateMapper.ensureInitialized().encodeJson<EntityState>(
      this as EntityState,
    );
  }

  Map<String, dynamic> toMap() {
    return EntityStateMapper.ensureInitialized().encodeMap<EntityState>(
      this as EntityState,
    );
  }

  EntityStateCopyWith<EntityState, EntityState, EntityState> get copyWith =>
      _EntityStateCopyWithImpl<EntityState, EntityState>(
        this as EntityState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return EntityStateMapper.ensureInitialized().stringifyValue(
      this as EntityState,
    );
  }

  @override
  bool operator ==(Object other) {
    return EntityStateMapper.ensureInitialized().equalsValue(
      this as EntityState,
      other,
    );
  }

  @override
  int get hashCode {
    return EntityStateMapper.ensureInitialized().hashValue(this as EntityState);
  }
}

extension EntityStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EntityState, $Out> {
  EntityStateCopyWith<$R, EntityState, $Out> get $asEntityState =>
      $base.as((v, t, t2) => _EntityStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EntityStateCopyWith<$R, $In extends EntityState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, Snowflake, Guild, GuildCopyWith<$R, Guild, Guild>> get guilds;
  MapCopyWith<
    $R,
    Snowflake,
    List<Channel>,
    ObjectCopyWith<$R, List<Channel>, List<Channel>>
  >
  get guildChannels;
  ListCopyWith<$R, Snowflake, SnowflakeCopyWith<$R, Snowflake, Snowflake>>
  get guildIds;
  ListCopyWith<
    $R,
    GuildFolder,
    GuildFolderCopyWith<$R, GuildFolder, GuildFolder>
  >
  get guildFolders;
  $R call({
    Map<Snowflake, Guild>? guilds,
    Map<Snowflake, List<Channel>>? guildChannels,
    List<Snowflake>? guildIds,
    List<GuildFolder>? guildFolders,
  });
  EntityStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EntityStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EntityState, $Out>
    implements EntityStateCopyWith<$R, EntityState, $Out> {
  _EntityStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EntityState> $mapper =
      EntityStateMapper.ensureInitialized();
  @override
  MapCopyWith<$R, Snowflake, Guild, GuildCopyWith<$R, Guild, Guild>>
  get guilds => MapCopyWith(
    $value.guilds,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(guilds: v),
  );
  @override
  MapCopyWith<
    $R,
    Snowflake,
    List<Channel>,
    ObjectCopyWith<$R, List<Channel>, List<Channel>>
  >
  get guildChannels => MapCopyWith(
    $value.guildChannels,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(guildChannels: v),
  );
  @override
  ListCopyWith<$R, Snowflake, SnowflakeCopyWith<$R, Snowflake, Snowflake>>
  get guildIds => ListCopyWith(
    $value.guildIds,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(guildIds: v),
  );
  @override
  ListCopyWith<
    $R,
    GuildFolder,
    GuildFolderCopyWith<$R, GuildFolder, GuildFolder>
  >
  get guildFolders => ListCopyWith(
    $value.guildFolders,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(guildFolders: v),
  );
  @override
  $R call({
    Map<Snowflake, Guild>? guilds,
    Map<Snowflake, List<Channel>>? guildChannels,
    List<Snowflake>? guildIds,
    List<GuildFolder>? guildFolders,
  }) => $apply(
    FieldCopyWithData({
      if (guilds != null) #guilds: guilds,
      if (guildChannels != null) #guildChannels: guildChannels,
      if (guildIds != null) #guildIds: guildIds,
      if (guildFolders != null) #guildFolders: guildFolders,
    }),
  );
  @override
  EntityState $make(CopyWithData data) => EntityState(
    guilds: data.get(#guilds, or: $value.guilds),
    guildChannels: data.get(#guildChannels, or: $value.guildChannels),
    guildIds: data.get(#guildIds, or: $value.guildIds),
    guildFolders: data.get(#guildFolders, or: $value.guildFolders),
  );

  @override
  EntityStateCopyWith<$R2, EntityState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EntityStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

