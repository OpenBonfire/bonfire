import 'package:bonfire/features/user/controllers/presence.dart';
import 'package:bonfire/shared/utils/presence.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class PresenceText extends ConsumerStatefulWidget {
  final Snowflake userid;
  final PresenceUpdateEvent? initialPresence;
  const PresenceText({
    super.key,
    required this.userid,
    this.initialPresence,
  });

  @override
  ConsumerState<PresenceText> createState() => _PresenceTextState();
}

class _PresenceTextState extends ConsumerState<PresenceText> {
  @override
  Widget build(BuildContext context) {
    PresenceUpdateEvent? presence =
        ref.watch(presenceControllerProvider(widget.userid)) ??
            widget.initialPresence;

    (String?, String?)? calculatedPresenceMessage;

    if (presence?.activities != null) {
      calculatedPresenceMessage =
          calculatePresenceMessage(presence!.activities!);
    }
    if (calculatedPresenceMessage != null) {
      return RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: GoogleFonts.publicSans(
            color: Theme.of(context).custom.colorTheme.deselectedChannelText,
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
          children: [
            if (calculatedPresenceMessage.$1 != null)
              TextSpan(
                text: "${calculatedPresenceMessage.$1} ",
                style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w400,
                ),
              ),
            if (calculatedPresenceMessage.$2 != null)
              TextSpan(
                text: calculatedPresenceMessage.$2,
                style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
