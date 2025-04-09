import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/features/me/components/member_card.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_platform/universal_platform.dart';

class TopButtons extends ConsumerStatefulWidget {
  final Snowflake channelId;

  const TopButtons({
    super.key,
    required this.channelId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TopButtonsState();
}

class _TopButtonsState extends ConsumerState<TopButtons> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopButton(
          channelId: widget.channelId,
        ),
      ],
    );
  }
}

class TopButton extends ConsumerStatefulWidget {
  final Snowflake channelId;

  const TopButton({
    super.key,
    required this.channelId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TopButtonState();
}

class _TopButtonState extends ConsumerState<TopButton> {
  @override
  Widget build(BuildContext context) {
    bool selected = widget.channelId == Snowflake.zero;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.all(4),
            side: const BorderSide(
              color: Colors.transparent,
              width: 0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            foregroundColor: selected
                ? Theme.of(context).custom.colorTheme.dirtyWhite
                : Theme.of(context).custom.colorTheme.gray,
            backgroundColor: selected
                ? Theme.of(context).custom.colorTheme.foreground
                : Colors.transparent),
        onPressed: () {
          HapticFeedback.selectionClick();
          GoRouter.of(context).go("/channels/@me");
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // friends icon
            Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.people,
                color: selected
                    ? Theme.of(context).custom.colorTheme.dirtyWhite
                    : Theme.of(context).custom.colorTheme.gray,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "Friends",
                      style: Theme.of(context).custom.textTheme.subtitle1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivateMessages extends ConsumerStatefulWidget {
  final Snowflake channelId;
  const PrivateMessages({
    super.key,
    required this.channelId,
  });

  @override
  ConsumerState<PrivateMessages> createState() => _PrivateMessagesState();
}

class _PrivateMessagesState extends ConsumerState<PrivateMessages> {
  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).padding.top +
        (UniversalPlatform.isDesktopOrWeb ? 8 : 0);
    double bottomPadding = UniversalPlatform.isMobile
        ? MediaQuery.of(context).padding.bottom + 68
        : 0;
    var dms = ref.watch(privateMessageHistoryProvider).toList();

    // sort by numerical ids
    dms.sort((a, b) {
      BigInt aLastMessageId =
          (a as TextChannel).lastMessageId?.value ?? BigInt.zero;
      var bLastMessageId =
          (b as TextChannel).lastMessageId?.value ?? BigInt.zero;
      return bLastMessageId.compareTo(aLastMessageId);
    });

    return Scaffold(
      body: Padding(
          padding: EdgeInsets.only(left: 8, top: topPadding, bottom: 0),
          child: SizedBox(
              width: double.infinity,
              child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).custom.colorTheme.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context)
                                  .custom
                                  .colorTheme
                                  .foreground,
                              width: 1.0))),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: bottomPadding),
                          itemCount: dms.length,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return TopButtons(
                                channelId: widget.channelId,
                              );
                            }
                            return DirectMessageMember(
                              privateChannel: dms[index - 1],
                              currentChannelId: widget.channelId,
                            );
                          },
                        ),
                      ),
                    ],
                  )))),
    );
  }
}
