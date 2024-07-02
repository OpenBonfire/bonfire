import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/features/me/views/components/member_card.dart';
import 'package:bonfire/features/me/views/components/overview_card.dart';
import 'package:bonfire/features/members/views/components/member_card.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageOverview extends ConsumerStatefulWidget {
  const MessageOverview({super.key});

  @override
  ConsumerState<MessageOverview> createState() => _MessageOverviewState();
}

class _MessageOverviewState extends ConsumerState<MessageOverview> {
  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).padding.top;
    // TODO: the +50 is for the nav bar, account for desktop
    var bottomPadding = MediaQuery.of(context).padding.bottom + 68;
    var dms = ref.watch(privateMessageHistoryProvider).reversed.toList();

    return Scaffold(
      body: Padding(
          padding:
              EdgeInsets.only(left: 8, top: topPadding, bottom: bottomPadding),
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
                        topRight: Radius.circular(8),
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
                          padding: EdgeInsets.zero,
                          itemCount: dms.length,
                          itemBuilder: (context, index) {
                            return DirectMessageMember(
                              privateChannel: dms[index],
                            );
                          },
                        ),
                      ),
                    ],
                  )))),
    );
  }
}
