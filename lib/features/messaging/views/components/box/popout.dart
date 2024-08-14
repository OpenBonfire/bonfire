import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';

class ContextPopout extends StatelessWidget {
  const ContextPopout({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        offset: const Offset(0, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        color: Theme.of(context).custom.colorTheme.foreground,
        elevation: 10,
        onSelected: (String result) {
          print('Selected: $result');
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'reply',
            height: 36,
            child: Text('Reply', style: TextStyle(color: Colors.white)),
          ),
          // const PopupMenuItem<String>(
          //   value: 'delete',
          //   height: 36,
          //   child: Text('Delete', style: TextStyle(color: Colors.white)),
          // ),
        ],
        position: PopupMenuPosition.under,
        splashRadius: 0,
        tooltip: '',
        enableFeedback: false,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.foreground,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.more_horiz,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
