import 'dart:math';

import 'package:bonfire/theme/text_theme.dart';
import 'package:flutter/material.dart';

class OverviewCard extends StatelessWidget {
  const OverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    "Messages",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Transform.rotate(
                    angle: pi / 2,
                    child: const Icon(Icons.expand_less_rounded)),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 12,
        )
      ],
    );
  }
}
