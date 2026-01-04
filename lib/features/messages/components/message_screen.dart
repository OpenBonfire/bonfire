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
            borderRadius: .circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                DefaultTextStyle(
                  style: theme.textTheme.titleMedium!,
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

        Expanded(child: child),
      ],
    );
  }
}
