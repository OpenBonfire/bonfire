import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class MessagesIcon extends StatelessWidget {
  final bool selected;

  const MessagesIcon({super.key, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: SizedBox(
            width: 47,
            height: 47,
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                GoRouter.of(context).go('/channels/@me');
              },
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(selected ? 15 : 100)),
                child: Transform.scale(
                  scale: 0.4,
                  child: SvgPicture.asset(
                    'assets/icons/dms.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (selected)
          Positioned(
            left: 0,
            child: Container(
              width: 4,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
            ),
          )
      ],
    );
  }
}
