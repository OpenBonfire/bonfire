import 'package:firebridge/src/builders/image.dart';
import 'package:firebridge/src/models/channel/types/forum.dart';
import 'package:firebridge/src/models/guild/scheduled_event.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/utils/flags.dart';

// ASCII encoded "nyxx"
const sentinelInteger = 0x6E797878;

// ESC-"nyxx"
const sentinelString = '\u{1B}nyxx';

const sentinelDuration = _SentinelDuration();

class _SentinelDuration implements Duration {
  const _SentinelDuration();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelSnowflake = _SentinelSnowflake();

class _SentinelSnowflake implements Snowflake {
  const _SentinelSnowflake();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelDefaultReaction = _SentinelDefaultReaction();

class _SentinelDefaultReaction implements DefaultReaction {
  const _SentinelDefaultReaction();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelList = _SentinelList();

class _SentinelList implements List<Never> {
  const _SentinelList();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelImageBuilder = _SentinelImageBuilder();

class _SentinelImageBuilder implements ImageBuilder {
  const _SentinelImageBuilder();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelDateTime = _SentinelDateTime();

class _SentinelDateTime implements DateTime {
  const _SentinelDateTime();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelEntityMetadata = _SentinelEntityMetadata();

class _SentinelEntityMetadata implements EntityMetadata {
  const _SentinelEntityMetadata();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelMap = _SentinelMap();

class _SentinelMap implements Map<Never, Never> {
  const _SentinelMap();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelFlags = _SentinelFlags();

class _SentinelFlags implements Flags<Never> {
  const _SentinelFlags();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const sentinelUri = _SentinelUri();

class _SentinelUri implements Uri {
  const _SentinelUri();

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
