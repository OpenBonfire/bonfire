// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(messageAuthorName)
const messageAuthorNameProvider = MessageAuthorNameFamily._();

final class MessageAuthorNameProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const MessageAuthorNameProvider._({
    required MessageAuthorNameFamily super.from,
    required (Snowflake, Channel, MessageAuthor) super.argument,
  }) : super(
         retry: null,
         name: r'messageAuthorNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messageAuthorNameHash();

  @override
  String toString() {
    return r'messageAuthorNameProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as (Snowflake, Channel, MessageAuthor);
    return messageAuthorName(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageAuthorNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageAuthorNameHash() => r'9584b97afc689793f4e22daf2889dbec7eb17850';

final class MessageAuthorNameFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<String?>,
          (Snowflake, Channel, MessageAuthor)
        > {
  const MessageAuthorNameFamily._()
    : super(
        retry: null,
        name: r'messageAuthorNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MessageAuthorNameProvider call(
    Snowflake guildId,
    Channel channel,
    MessageAuthor author,
  ) => MessageAuthorNameProvider._(
    argument: (guildId, channel, author),
    from: this,
  );

  @override
  String toString() => r'messageAuthorNameProvider';
}
