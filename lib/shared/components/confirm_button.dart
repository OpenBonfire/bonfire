import 'package:flutter/material.dart';

class BonfireButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Widget child;

  const BonfireButton({
    super.key,

    required this.onPressed,
    required this.child,
  });

  @override
  State<BonfireButton> createState() => _BonfireButtonState();
}

class _BonfireButtonState extends State<BonfireButton> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTextStyle(
      style: theme.textTheme.labelMedium!,
      child: InkWell(
        onTap: () async {
          setState(() {
            _loading = true;
          });
          await widget.onPressed?.call();
          setState(() {
            _loading = false;
          });
        },
        child: Padding(padding: const EdgeInsets.all(8.0), child: widget.child),
      ),
    );
  }
}
