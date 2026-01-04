import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  final Text title;
  final Text? description;
  final Widget child;
  const MessageScreen({
    super.key,
    required this.title,
    this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: .start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: .circular(0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                DefaultTextStyle(
                  style: theme.textTheme.titleSmall!,
                  child: title,
                ),
                if (description != null)
                  DefaultTextStyle(
                    style: theme.textTheme.labelMedium!.copyWith(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: description!,
                  ),
              ],
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Container(
              // decoration: BoxDecoration(
              //   color: theme.colorScheme.surfaceContainerLowest,
              // ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
