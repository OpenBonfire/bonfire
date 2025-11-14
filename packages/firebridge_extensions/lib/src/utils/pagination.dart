import 'dart:async';

import 'package:firebridge/firebridge.dart';

/// {@template pagination_options}
/// Options for controlling pagination.
/// {@endtemplate}
class PaginationOptions {
  /// Whether to show the jump to start and jump to end buttons.
  ///
  /// Defaults to `true`.
  final bool? showJumpToEnds;

  /// Whether to show the page index in a button centered between the navigation buttons.
  ///
  /// Defaults to true.
  final bool? showPageIndex;

  /// The button style to use for the page index button.
  ///
  /// Defaults to [ButtonStyle.secondary].
  final ButtonStyle? pageIndexStyle;

  /// The label to display on the jump to start button.
  ///
  /// Defaults to `<<`.
  final String? jumpToStartLabel;

  /// The style to use for the jump to start button.
  ///
  /// Defaults to [ButtonStyle.secondary].
  final ButtonStyle? jumpToStartStyle;

  /// The emoji to show on the jump to start button.
  final Emoji? jumpToStartEmoji;

  /// The label to show on the jump to end button.
  ///
  /// Defaults to `>>`.
  final String? jumpToEndLabel;

  /// The style to use for the jump to end button.
  ///
  /// Defaults to [ButtonStyle.secondary].
  final ButtonStyle? jumpToEndStyle;

  /// The emoji to show on the jump to end button.
  final Emoji? jumpToEndEmoji;

  /// The label to show on the previous button.
  ///
  /// Defaults to `<`.
  final String? previousLabel;

  /// The style to use for the previous button.
  ///
  /// Defaults to [ButtonStyle.primary].
  final ButtonStyle? previousStyle;

  /// The emoji to show on the previous button.
  final Emoji? previousEmoji;

  /// The label to show on the next button.
  ///
  /// Defaults to `>`.
  final String? nextLabel;

  /// The style to use for the next button.
  ///
  /// Defaults to [ButtonStyle.primary].
  final ButtonStyle? nextStyle;

  /// The emoji to show on the next button.
  final Emoji? nextEmoji;

  /// The time after which the pagination should be disabled.
  final Duration? timeout;

  /// Whether to disable all active paginated messages when the client closes.
  ///
  /// This prevents paginated messages from being left "dangling" and resulting in [Pagination.onUnhandledInteraction].
  final bool? disableOnClientClose;

  /// {@macro pagination_options}
  PaginationOptions({
    this.showJumpToEnds,
    this.showPageIndex,
    this.pageIndexStyle,
    this.jumpToStartLabel,
    this.jumpToStartStyle,
    this.jumpToStartEmoji,
    this.jumpToEndLabel,
    this.jumpToEndStyle,
    this.jumpToEndEmoji,
    this.previousLabel,
    this.previousStyle,
    this.previousEmoji,
    this.nextLabel,
    this.nextStyle,
    this.nextEmoji,
    this.timeout,
    this.disableOnClientClose,
  });
}

/// A global instance of the [Pagination] plugin with default options.
final pagination = Pagination(PaginationOptions());

/// A plugin that adds support for pagination to nyxx clients.
///
/// This plugin must be registered to all clients making use of the pagination features.
class Pagination extends NyxxPlugin<NyxxGateway> {
  @override
  String get name => 'Pagination';

  /// The default options to use for all paginated messages.
  final PaginationOptions options;

  final Map<String, _PaginationState> _states = {};
  final Map<Nyxx, Set<_PaginationState>> _clientStates = {};

  /// A stream of interactions that were recognized as being created by a [Pagination] plugin different to this one.
  ///
  /// This is often a sign of leftover menus from a previous client session.
  Stream<InteractionCreateEvent<MessageComponentInteraction>>
      get onUnhandledInteraction => _unhandledInteractionsController.stream;
  final StreamController<InteractionCreateEvent<MessageComponentInteraction>>
      _unhandledInteractionsController = StreamController.broadcast();

  /// A stream of interactions that were recognized by this plugin but were not handled because the wrong user triggered the interaction.
  Stream<InteractionCreateEvent<MessageComponentInteraction>>
      get onDisallowedUse => _disallowedUseController.stream;
  final StreamController<InteractionCreateEvent<MessageComponentInteraction>>
      _disallowedUseController = StreamController.broadcast();

  /// Create a new [Pagination] instance.
  Pagination(this.options);

  void _registerPagination(_PaginationState state) {
    _states[state.jumpToStartId] = state;
    _states[state.previousId] = state;
    _states[state.nextId] = state;
    _states[state.jumpToEndId] = state;
  }

  void _unregisterPagination(_PaginationState state) {
    _states.remove(state.jumpToStartId);
    _states.remove(state.previousId);
    _states.remove(state.nextId);
    _states.remove(state.jumpToEndId);

    for (final clientStates in _clientStates.values) {
      clientStates.remove(state);
    }
  }

  @override
  void afterConnect(NyxxGateway client) async {
    client.onMessageComponentInteraction.listen((event) async {
      final interaction = event.interaction;
      final data = interaction.data;

      if (data.type != MessageComponentType.button) {
        return;
      }

      final state = _states[data.customId];

      if (state == null) {
        if (data.customId.startsWith('nyxx_pagination/')) {
          _unhandledInteractionsController.add(event);
        }
        return;
      }

      if (state.userId != null &&
          (interaction.user?.id ?? interaction.member!.id) != state.userId) {
        _disallowedUseController.add(event);
        return;
      }

      if (data.customId == state.jumpToStartId) {
        state.currentIndex = 0;
      } else if (data.customId == state.previousId) {
        state.currentIndex--;
      } else if (data.customId == state.nextId) {
        state.currentIndex++;
      } else if (data.customId == state.jumpToEndId) {
        state.currentIndex = state.builders.length - 1;
      }

      await interaction.respond(
        updateMessage: true,
        _PaginationMessageUpdateBuilder(
            await state.builderForIndex(state.currentIndex)),
      );
    });

    client.onMessageCreate.listen((event) {
      final rows = (event.message.components?.cast<ActionRowComponent>()) ??
          <ActionRowComponent>[];
      final components = rows.expand((element) => element.components);

      for (final component in components.whereType<ButtonComponent>()) {
        final state = _states[component.customId];

        if (state == null) continue;

        (_clientStates[event.gateway.client] ??= {}).add(state);
        state.message = event.message;

        final timeout = state.options?.timeout ?? options.timeout;
        if (timeout != null) {
          state.disableTimer = Timer(timeout, () async {
            state.isDisabled = true;

            await event.message.update(_PaginationMessageUpdateBuilder(
              await state.builderForIndex(state.currentIndex),
            ));

            _unregisterPagination(state);
          });
        }

        break;
      }
    });
  }

  @override
  Future<void> beforeClose(NyxxGateway client) async {
    final clientStates = _clientStates.remove(client);
    if (clientStates != null) {
      await Future.wait(clientStates.map((state) async {
        _unregisterPagination(state);

        state.disableTimer?.cancel();
        if (state.options?.disableOnClientClose ??
            options.disableOnClientClose ??
            true) {
          state.isDisabled = true;

          await state.message?.update(_PaginationMessageUpdateBuilder(
            await state.builderForIndex(state.currentIndex),
          ));
        }
      }));
    }
  }

  /// Create a [MessageBuilder] for a paginated message created by a list of builder factories.
  ///
  /// Each page in the paginated message is created by calling the associated function in [builders].
  ///
  /// {@template pagination_parameters}
  /// [options] can be specified to override some of the default options.
  /// [startIndex] can be set to change the index of the page the pagination starts at.
  /// [userId] can be set to restrict usage of the menu to a single user. Users other than this user trying to use the paginated message will emit an
  /// interaction to [onDisallowedUse].
  /// {@endtemplate}
  Future<MessageBuilder> factories(
    List<FutureOr<MessageBuilder> Function()> builders, {
    PaginationOptions? options,
    int startIndex = 0,
    Snowflake? userId,
  }) async {
    final state = _PaginationState(this, options, builders, startIndex, userId);
    _registerPagination(state);

    return await state.builderForIndex(startIndex);
  }

  /// Create a [MessageBuilder] for a paginated message created by a builder factory.
  ///
  /// Each page in the paginated message is created by calling [builder] and passing the index of the page.
  /// [pages] controls the number of pages in the message.
  ///
  /// {@macro pagination_parameters}
  Future<MessageBuilder> generate(
    FutureOr<MessageBuilder> Function(int index) builder, {
    required int pages,
    PaginationOptions? options,
    int startIndex = 0,
    Snowflake? userId,
  }) {
    final builders = List.generate(
      pages,
      (index) => () => builder(index),
      growable: false,
    );

    return factories(builders,
        options: options, startIndex: startIndex, userId: userId);
  }

  /// Create a [MessageBuilder] for a paginated message created from a list of [MessageBuilder]s.
  ///
  /// {@macro pagination_parameters}
  Future<MessageBuilder> builders(
    List<MessageBuilder> builders, {
    PaginationOptions? options,
    int startIndex = 0,
    Snowflake? userId,
  }) {
    return generate(
      pages: builders.length,
      (index) => builders[index],
      options: options,
      startIndex: startIndex,
      userId: userId,
    );
  }

  /// Create a [MessageBuilder] for a paginated message created by splitting a long [String] into parts.
  ///
  /// [splitAt] can be specified to control where the content can be split. The default is to split at whitespace characters.
  /// [buildChunk] can be specified to configure how the message is created from a chunk of test. The default is to create a message containing the chunk's
  /// content.
  /// [maxLength] can be specified to set the maximum chunk length.
  /// {@macro pagination_parameters}
  ///
  /// If the split text contains chunks larger than [maxLength], the large chunks will be split at arbitrary characters to fit the length limit.
  Future<MessageBuilder> split(
    String content, {
    Pattern? splitAt,
    FutureOr<MessageBuilder> Function(String content)? buildChunk,
    int maxLength = 2000,
    PaginationOptions? options,
    Snowflake? userId,
  }) {
    buildChunk ??= (content) => MessageBuilder(content: content);
    splitAt ??= RegExp(r'\s+');

    final potentialSplices =
        splitAt.allMatches(content).map((match) => match.start);

    // 0 is the start of the very first chunk
    final splices = <int>[0];
    int currentSplice = 0;
    int lastSplice = 0;

    for (final potentialSplice in [...potentialSplices, content.length]) {
      while (potentialSplice - currentSplice > maxLength) {
        // Chunk between [potentialSplice] and the previous possible splice is > [maxLength].
        // Cut the chunk forcefully down the middle.
        final remaining = maxLength - (currentSplice - lastSplice);
        currentSplice += remaining;

        splices.add(currentSplice);
        lastSplice = currentSplice;
      }

      if (potentialSplice - lastSplice > maxLength) {
        // Choosing this splice would make the current chunk too long. Add the previous chunk and move on.
        splices.add(currentSplice);
        lastSplice = currentSplice;
        currentSplice = potentialSplice;
      } else {
        // Just grow the current chunk.
        currentSplice = potentialSplice;
      }
    }

    splices.add(currentSplice);

    return generate(
      pages: splices.length - 1,
      (index) =>
          buildChunk!(content.substring(splices[index], splices[index + 1])),
      options: options,
      userId: userId,
    );
  }

  /// Create a [MessageBuilder] for a paginated message created by splitting a long [String] into parts and placing the resulting text in [Embed]s.
  ///
  /// [splitAt] can be specified to control where the content can be split. The default is to split at whitespace characters.
  /// [buildChunk] can be specified to configure how the message is created from a chunk of test. The default is to create an containing the chunk's
  /// content as its description.
  /// [maxLength] can be specified to set the maximum chunk length.
  /// {@macro pagination_parameters}
  ///
  /// If the split text contains chunks larger than [maxLength], the large chunks will be split at arbitrary characters to fit the length limit.
  Future<MessageBuilder> splitEmbeds(
    String content, {
    Pattern? splitAt,
    FutureOr<EmbedBuilder> Function(String content)? buildChunk,
    int maxLength = 4096,
    PaginationOptions? options,
    Snowflake? userId,
  }) {
    buildChunk ??= (content) => EmbedBuilder(description: content);

    return split(
      content,
      splitAt: splitAt,
      maxLength: maxLength,
      buildChunk: (content) async =>
          MessageBuilder(embeds: [await buildChunk!(content)]),
      options: options,
      userId: userId,
    );
  }
}

class _PaginationState {
  final Pagination pagination;
  final PaginationOptions? options;
  final List<FutureOr<MessageBuilder> Function()> builders;

  final String jumpToStartId = generateId();
  final String jumpToEndId = generateId();
  final String previousId = generateId();
  final String nextId = generateId();

  static int idCounter = 0;
  static String generateId() =>
      'nyxx_pagination/${DateTime.now().millisecondsSinceEpoch}/${idCounter++}';

  final Snowflake? userId;

  Timer? disableTimer;
  Message? message;

  int currentIndex;
  bool isDisabled = false;

  _PaginationState(this.pagination, this.options, this.builders,
      this.currentIndex, this.userId);

  FutureOr<MessageBuilder> builderForIndex(int index) {
    final builder = builders[index]();

    if (builder is MessageBuilder) {
      addControls(builder, index);
      return builder;
    } else {
      return builder.then((builder) {
        addControls(builder, index);
        return builder;
      });
    }
  }

  void addControls(MessageBuilder builder, int index) {
    if (builder.components case List(length: >= 5)) {
      throw NyxxException(
          'Cannot add pagination controls to builder: too many component rows');
    }

    final knownIds = {jumpToStartId, jumpToEndId, previousId, nextId};
    if (builder.components?.any((row) => row.components.any((element) =>
            element is ButtonBuilder && knownIds.contains(element.customId))) ==
        true) {
      // We've already added controls to this builder, likely when the user navigated to this page previously.
      return;
    }

    final showJumpToEnds =
        options?.showJumpToEnds ?? pagination.options.showJumpToEnds ?? true;
    final showPageIndex =
        options?.showPageIndex ?? pagination.options.showPageIndex ?? true;

    builder
      ..components ??= []
      ..components!.add(ActionRowBuilder(components: [
        if (showJumpToEnds)
          ButtonBuilder(
            style: options?.jumpToStartStyle ??
                pagination.options.jumpToStartStyle ??
                ButtonStyle.secondary,
            label: options?.jumpToStartLabel ??
                pagination.options.jumpToStartLabel ??
                '<<',
            emoji: options?.jumpToStartEmoji ??
                pagination.options.jumpToStartEmoji,
            customId: jumpToStartId,
            isDisabled: isDisabled || index == 0,
          ),
        ButtonBuilder(
          style: options?.previousStyle ??
              pagination.options.previousStyle ??
              ButtonStyle.primary,
          label:
              options?.previousLabel ?? pagination.options.previousLabel ?? '<',
          emoji: options?.previousEmoji ?? pagination.options.previousEmoji,
          customId: previousId,
          isDisabled: isDisabled || index == 0,
        ),
        if (showPageIndex)
          ButtonBuilder(
            style: options?.pageIndexStyle ??
                pagination.options.pageIndexStyle ??
                ButtonStyle.secondary,
            label: '${index + 1}/${builders.length}',
            customId: 'nyxx_pagination/page_index_display',
            isDisabled: true,
          ),
        ButtonBuilder(
          style: options?.nextStyle ??
              pagination.options.nextStyle ??
              ButtonStyle.primary,
          label: options?.nextLabel ?? pagination.options.nextLabel ?? '>',
          emoji: options?.nextEmoji ?? pagination.options.nextEmoji,
          customId: nextId,
          isDisabled: isDisabled || index == builders.length - 1,
        ),
        if (showJumpToEnds)
          ButtonBuilder(
            style: options?.jumpToEndStyle ??
                pagination.options.jumpToEndStyle ??
                ButtonStyle.secondary,
            label: options?.jumpToEndLabel ??
                pagination.options.jumpToEndLabel ??
                '>>',
            emoji: options?.jumpToEndEmoji ?? pagination.options.jumpToEndEmoji,
            customId: jumpToEndId,
            isDisabled: isDisabled || index == builders.length - 1,
          ),
      ]));
  }
}

class _PaginationMessageUpdateBuilder extends MessageUpdateBuilder {
  final MessageBuilder target;

  _PaginationMessageUpdateBuilder(this.target)
      : super(
          content: target.content,
          embeds: target.embeds ?? [],
          suppressEmbeds: target.suppressEmbeds == true,
          attachments: target.attachments ?? [],
          components: target.components ?? [],
          allowedMentions: target.allowedMentions,
        );
}
