import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelMessageBar extends ConsumerStatefulWidget {
  final Snowflake channelId;
  const ChannelMessageBar({super.key, required this.channelId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChannelMessageBarState();
}

class _ChannelMessageBarState extends ConsumerState<ChannelMessageBar> {
  final TextEditingController _controller = TextEditingController();
  Future<void> _sendMessage() async {
    final content = _controller.text;
    _controller.clear();
    final client = ref.watch(clientControllerProvider)!;
    await client
        .messages(channelId: widget.channelId)
        .create(MessageBuilder(content: content));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final channel = ref.watch(channelProvider(widget.channelId));

    String name = "Channel Name";
    if (channel is GuildChannel) {
      name = channel.name;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 8, right: 8),
      child: TextField(
        controller: _controller,
        style: theme.textTheme.bodyMedium,
        minLines: 1,
        maxLines: 8,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _sendMessage(),
        decoration: InputDecoration(
          hintText: "Message #$name",
          filled: true,
          fillColor: theme.colorScheme.surfaceContainer,
          hintStyle: theme.textTheme.labelLarge!.copyWith(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(190),
            fontWeight: .w400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.surfaceContainerHigh,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
          ),
        ),
      ),
    );
  }
}
