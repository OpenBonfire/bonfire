import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/features/me/views/components/member_card.dart';
import 'package:bonfire/features/me/views/components/overview_card.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_platform/universal_platform.dart';

class PrivateMessages extends ConsumerStatefulWidget {
  final Snowflake channelId;
  const PrivateMessages({
    super.key,
    required this.channelId,
  });

  @override
  ConsumerState<PrivateMessages> createState() => _MessageOverviewState();
}

class _MessageOverviewState extends ConsumerState<PrivateMessages> {
  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).padding.top;
    double bottomPadding = UniversalPlatform.isMobile
        ? MediaQuery.of(context).padding.bottom + 68
        : 0;
    var dms = ref.watch(privateMessageHistoryProvider).toList();

    // sort by numerical ids
    dms.sort((a, b) {
      BigInt aLastMessageId = a.lastMessageId?.value ?? BigInt.zero;
      var bLastMessageId = b.lastMessageId?.value ?? BigInt.zero;
      return bLastMessageId.compareTo(aLastMessageId);
    });

    return Scaffold(
      body: Padding(
          padding: EdgeInsets.only(left: 8, top: topPadding, bottom: 0),
          child: SizedBox(
              width: double.infinity,
              child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context)
                          .custom
                          .colorTheme
                          .channelListBackground,
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
                      const OverviewCard(),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: bottomPadding),
                          itemCount: dms.length,
                          itemBuilder: (context, index) {
                            return DirectMessageMember(
                              privateChannel: dms[index],
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
