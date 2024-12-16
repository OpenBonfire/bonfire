import 'dart:ui';
import 'package:bonfire/features/overview/controllers/member_list.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ChannelHeader extends ConsumerStatefulWidget {
  final String channelName;
  const ChannelHeader({super.key, required this.channelName});

  @override
  ConsumerState<ChannelHeader> createState() => _ChannelHeaderState();
}

class _ChannelHeaderState extends ConsumerState<ChannelHeader> {
  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 4),
          child: Container(
            height: topPadding + 50,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          "# ${widget.channelName}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: GoogleFonts.publicSans(
                            fontSize: 16,
                            letterSpacing: 0.4,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (shouldUseDesktopLayout(context))
                    IconButton(
                      icon: const Icon(Icons.group_rounded),
                      onPressed: () {
                        ref
                            .read(memberListVisibilityProvider.notifier)
                            .toggleVisibility();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
