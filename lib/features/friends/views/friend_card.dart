import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendCard extends ConsumerStatefulWidget {
  const FriendCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FriendCardState();
}

class _FriendCardState extends ConsumerState<FriendCard> {
  bool selected = true;

  @override
  Widget build(BuildContext context) {
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
                ? Theme.of(context).custom.colorTheme.selectedChannelText
                : Theme.of(context).custom.colorTheme.deselectedChannelText,
            backgroundColor: selected
                ? Theme.of(context).custom.colorTheme.foreground
                : Colors.transparent),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.people,
                color: selected
                    ? Theme.of(context).custom.colorTheme.selectedChannelText
                    : Theme.of(context).custom.colorTheme.deselectedChannelText,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Friend Card",
                    style: Theme.of(context).custom.textTheme.subtitle1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "I will finish this bit soon. I gotta finish it in firebridge first :D.",
                    style: GoogleFonts.publicSans(
                      color: Theme.of(context)
                          .custom
                          .colorTheme
                          .deselectedChannelText,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
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
