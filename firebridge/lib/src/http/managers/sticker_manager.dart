import 'dart:convert';

import 'package:http/http.dart';
import 'package:firebridge/src/builders/sticker.dart';
import 'package:firebridge/src/http/managers/manager.dart';
import 'package:firebridge/src/http/request.dart';
import 'package:firebridge/src/http/route.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/models/sticker/global_sticker.dart';
import 'package:firebridge/src/models/sticker/guild_sticker.dart';
import 'package:firebridge/src/models/sticker/sticker.dart';
import 'package:firebridge/src/models/sticker/sticker_pack.dart';
import 'package:firebridge/src/utils/cache_helpers.dart';
import 'package:firebridge/src/utils/parsing_helpers.dart';

class GuildStickerManager extends Manager<GuildSticker> {
  final Snowflake guildId;

  GuildStickerManager(super.config, super.client, {required this.guildId})
      : super(identifier: "$guildId.stickers");

  @override
  PartialGuildSticker operator [](Snowflake id) =>
      PartialGuildSticker(id: id, manager: this);

  @override
  GuildSticker parse(Map<String, Object?> raw) {
    return GuildSticker(
      manager: this,
      id: Snowflake.parse(raw['id']!),
      name: raw['name'] as String,
      description: raw['description'] as String?,
      tags: raw['tags'] as String,
      type: StickerType.parse(raw['type'] as int),
      formatType: StickerFormatType.parse(raw['format_type'] as int),
      available: raw['available'] as bool? ?? false,
      guildId: Snowflake.parse(raw['guild_id']!),
      user: ((raw['user'] ?? {}) as Map)['id'] != null
          ? client.users[
              Snowflake.parse((raw['user'] as Map<String, Object?>)['id']!)]
          : null,
      sortValue: raw['sort_value'] as int?,
    );
  }

  @override
  Future<GuildSticker> create(StickerBuilder builder,
      {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..stickers();
    final request = FormDataRequest(route,
        method: 'POST',
        formParams: builder.build().cast<String, String>(),
        files: [MultipartFile.fromBytes('file', builder.file.buildRawData())],
        auditLogReason: auditLogReason);

    final response = await client.httpHandler.executeSafe(request);
    final sticker = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(sticker);
    return sticker;
  }

  Future<List<GuildSticker>> list() async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..stickers();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final stickers = parseMany(response.jsonBody as List<Object?>,
        (Map<String, Object?> raw) => parse(raw));

    stickers.forEach(client.updateCacheWith);
    return stickers;
  }

  @override
  Future<void> delete(Snowflake id, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..stickers(id: id.toString());
    final request =
        BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }

  @override
  Future<GuildSticker> fetch(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..stickers(id: id.toString());

    final request = BasicRequest(route);
    final response = await client.httpHandler.executeSafe(request);

    final sticker = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(sticker);
    return sticker;
  }

  @override
  Future<GuildSticker> update(Snowflake id, StickerUpdateBuilder builder,
      {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..stickers(id: id.toString());

    final request = BasicRequest(route,
        body: jsonEncode(builder.build()),
        method: 'PATCH',
        auditLogReason: auditLogReason);
    final response = await client.httpHandler.executeSafe(request);

    final sticker = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(sticker);
    return sticker;
  }
}

class GlobalStickerManager extends ReadOnlyManager<GlobalSticker> {
  GlobalStickerManager(super.config, super.client)
      : super(identifier: 'stickers');

  @override
  PartialGlobalSticker operator [](Snowflake id) =>
      PartialGlobalSticker(id: id, manager: this);

  @override
  GlobalSticker parse(Map<String, Object?> raw) {
    return GlobalSticker(
      manager: this,
      id: Snowflake.parse(raw['id']!),
      packId: Snowflake.parse(raw['pack_id']!),
      name: raw['name'] as String,
      description: raw['description'] as String?,
      tags: raw['tags'] as String,
      type: StickerType.parse(raw['type'] as int),
      formatType: StickerFormatType.parse(raw['format_type'] as int),
      available: raw['available'] as bool? ?? false,
      user: ((raw['user'] ?? {}) as Map)['id'] != null
          ? client.users[
              Snowflake.parse((raw['user'] as Map<String, Object?>)['id']!)]
          : null,
      sortValue: raw['sort_value'] as int?,
    );
  }

  StickerItem parseStickerItem(Map<String, Object?> raw) {
    return StickerItem(
      id: Snowflake.parse(raw['id']!),
      name: raw['name'] as String,
      formatType: StickerFormatType.parse(raw['format_type'] as int),
    );
  }

  StickerPack parseStickerPack(Map<String, Object?> raw) {
    return StickerPack(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      stickers: (raw['stickers'] as List)
          .map((e) => parse(e as Map<String, Object?>))
          .toList(),
      name: raw['name'] as String,
      skuId: Snowflake.parse(raw['sku_id']!),
      coverStickerId: raw['cover_sticker_id'] != null
          ? Snowflake.parse(raw['cover_sticker_id']!)
          : null,
      description: raw['description'] as String,
      bannerAssetId: raw['banner_asset_id'] != null
          ? Snowflake.parse(raw['banner_asset_id']!)
          : null,
    );
  }

  @override
  Future<GlobalSticker> fetch(Snowflake id) async {
    final route = HttpRoute()..stickers(id: id.toString());

    final request = BasicRequest(route);
    final response = await client.httpHandler.executeSafe(request);

    final sticker = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(sticker);
    return sticker;
  }

  Future<StickerPack> fetchStickerPack(Snowflake id) async {
    final route = HttpRoute()..stickerPacks(id: id.toString());
    final request = BasicRequest(route);

    final response = (await client.httpHandler.executeSafe(request)).jsonBody
        as Map<String, Object?>;
    final pack = parseStickerPack(response);

    client.updateCacheWith(pack);
    return pack;
  }

  Future<List<StickerPack>> fetchNitroStickerPacks() async {
    final route = HttpRoute()..stickerPacks();
    final request = BasicRequest(route);

    final response = (await client.httpHandler.executeSafe(request)).jsonBody
        as Map<String, Object?>;
    final packs =
        parseMany(response['sticker_packs'] as List, parseStickerPack);

    packs.forEach(client.updateCacheWith);
    return packs;
  }
}
