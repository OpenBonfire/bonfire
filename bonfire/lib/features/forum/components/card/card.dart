import 'package:bonfire/features/forum/controllers/forum.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ThreadCard extends ConsumerStatefulWidget {
  final Snowflake threadId;
  final Snowflake channelId;

  const ThreadCard({
    super.key,
    required this.threadId,
    required this.channelId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ThreadCardState();
}

class _ThreadCardState extends ConsumerState<ThreadCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // a bit of a hack, this can probably be done using other thread types so that should be handled
    PublicThread thread =
        ref.watch(threadChannelProvider(widget.threadId)) as PublicThread;

    Message? previewMessage = ref.watch(firstMessageProvider(widget.threadId));

    final bonfireTheme = BonfireThemeExtension.of(context);

    return Container(
      decoration: BoxDecoration(
        color: BonfireThemeExtension.of(context).foreground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        // hoverColor: BonfireThemeExtension.of(context).foreground,
        splashColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          debugPrint("should navigate");
          debugPrint("${widget.channelId}/${thread.id}");
          // debugPrint(thread.);
          // context.go("/channels/${thread.guildId}/${thread.id}/");
          context.go(
              "/channels/${thread.guildId}/${widget.channelId}/threads/${thread.id}/");
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (previewMessage != null)
                      ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxHeight: 50, minHeight: 0),
                        child: Text(
                          previewMessage.content,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                  ],
                ),
              ),
              if (previewMessage?.attachments.isNotEmpty == true &&
                  previewMessage!.attachments.first.contentType
                          ?.split("/")[0] ==
                      "image")
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    previewMessage.attachments.first.url.toString(),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
