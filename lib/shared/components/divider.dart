import 'package:flutter/material.dart';

class BonfireVerticalDivider extends StatelessWidget {
  final double width;
  const BonfireVerticalDivider({super.key, this.width = 1.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: double.infinity,
      width: width,
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer),
    );
  }
}

class BonfireHorizontalDivider extends StatelessWidget {
  final double width;
  const BonfireHorizontalDivider({super.key, this.width = 1.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
