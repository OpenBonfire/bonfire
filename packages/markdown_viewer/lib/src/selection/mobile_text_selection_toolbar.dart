import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _kHandleSize = 22.0;
const _kToolbarContentDistance = 8.0;
const _kToolbarContentDistanceBelow = _kHandleSize - 2.0;

class _TextSelectionToolbarItemData {
  const _TextSelectionToolbarItemData({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
}

class MobileTextSelectionToolbar extends StatelessWidget {
  const MobileTextSelectionToolbar({
    required this.clipboardStatus,
    required this.delegate,
    required this.endpoints,
    required this.globalEditableRegion,
    required this.handleCopy,
    required this.handleSelectAll,
    required this.selectionMidpoint,
    required this.textLineHeight,
    super.key,
  });

  final ClipboardStatusNotifier? clipboardStatus;
  final TextSelectionDelegate delegate;
  final List<TextSelectionPoint> endpoints;
  final Rect globalEditableRegion;
  final VoidCallback? handleCopy;
  final VoidCallback? handleSelectAll;
  final Offset selectionMidpoint;
  final double textLineHeight;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final itemDatas = <_TextSelectionToolbarItemData>[
      if (handleCopy != null)
        _TextSelectionToolbarItemData(
          label: localizations.copyButtonLabel,
          onPressed: handleCopy!,
        ),
      if (handleSelectAll != null)
        _TextSelectionToolbarItemData(
          label: localizations.selectAllButtonLabel,
          onPressed: handleSelectAll!,
        ),
    ];

    if (itemDatas.isEmpty) {
      return const SizedBox.shrink();
    }

    final startTextSelectionPoint = endpoints[0];
    final topAmountInEditableRegion =
        startTextSelectionPoint.point.dy - textLineHeight;
    final anchorTop = math.max(topAmountInEditableRegion, 0) +
        globalEditableRegion.top -
        _kToolbarContentDistance;
    final anchorAbove = Offset(
      globalEditableRegion.left + selectionMidpoint.dx,
      anchorTop,
    );
    final endTextSelectionPoint =
        endpoints.length > 1 ? endpoints[1] : endpoints[0];
    final anchorBelow = Offset(
      globalEditableRegion.left + selectionMidpoint.dx,
      globalEditableRegion.top +
          endTextSelectionPoint.point.dy +
          _kToolbarContentDistanceBelow,
    );

    return TextSelectionToolbar(
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      children: itemDatas
          .asMap()
          .entries
          .map(
            (MapEntry<int, _TextSelectionToolbarItemData> entry) =>
                TextSelectionToolbarTextButton(
              padding: TextSelectionToolbarTextButton.getPadding(
                entry.key,
                itemDatas.length,
              ),
              onPressed: entry.value.onPressed,
              child: Text(entry.value.label),
            ),
          )
          .toList(),
    );
  }
}
