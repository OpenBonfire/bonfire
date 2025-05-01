import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/material.dart';

// See: /flutter/lib/src/material/desktop_text_selection.dart

const _kToolbarScreenPadding = 8.0;
const _kToolbarWidth = 222.0;
const _kToolbarButtonFontStyle = TextStyle(
  inherit: false,
  fontSize: 14.0,
  letterSpacing: -0.15,
  fontWeight: FontWeight.w400,
);

const _kToolbarButtonPadding = EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 3.0);

class DesktopTextSelectionToolbarCustom extends StatelessWidget {
  const DesktopTextSelectionToolbarCustom({
    required this.clipboardStatus,
    required this.endpoints,
    required this.globalEditableRegion,
    required this.handleCopy,
    required this.handleSelectAll,
    required this.selectionMidpoint,
    required this.textLineHeight,
    required this.lastSecondaryTapDownPosition,
    super.key,
  });

  final ClipboardStatusNotifier? clipboardStatus;
  final List<TextSelectionPoint> endpoints;
  final Rect globalEditableRegion;
  final VoidCallback? handleCopy;
  final VoidCallback? handleSelectAll;
  final Offset? lastSecondaryTapDownPosition;
  final Offset selectionMidpoint;
  final double textLineHeight;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final size = MediaQuery.sizeOf(context);

    final localizations = MaterialLocalizations.of(context);
    final items = [
      if (handleCopy != null)
        _DesktopTextSelectionToolbarButton.text(
          context: context,
          onPressed: handleCopy!,
          text: localizations.copyButtonLabel,
        ),
      if (handleSelectAll != null)
        _DesktopTextSelectionToolbarButton.text(
          context: context,
          onPressed: handleSelectAll!,
          text: localizations.selectAllButtonLabel,
        )
    ];

    // If there is no option available, build an empty widget.
    if (items.isEmpty) {
      return const SizedBox(width: 0.0, height: 0.0);
    }

    final midpointAnchor = Offset(
      clampDouble(
        selectionMidpoint.dx - globalEditableRegion.left,
        padding.left,
        size.width - padding.right,
      ),
      selectionMidpoint.dy - globalEditableRegion.top,
    );

    return _DesktopTextSelectionToolbar(
      anchor: lastSecondaryTapDownPosition ?? midpointAnchor,
      children: items,
    );
  }
}

class _DesktopTextSelectionToolbar extends StatelessWidget {
  /// Creates an instance of _DesktopTextSelectionToolbar.
  const _DesktopTextSelectionToolbar({
    required this.anchor,
    required this.children,
  }) : assert(children.length > 0);

  /// The point at which the toolbar will attempt to position itself as closely
  /// as possible.
  final Offset anchor;

  /// See also:
  ///   * [DesktopTextSelectionToolbarButton], which builds a default
  ///     Material-style desktop text selection toolbar text button.
  final List<Widget> children;

  // Builds a desktop toolbar in the Material style.
  static Widget _defaultToolbarBuilder(BuildContext context, Widget child) {
    return SizedBox(
      width: _kToolbarWidth,
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(7.0)),
        clipBehavior: Clip.antiAlias,
        elevation: 1.0,
        type: MaterialType.card,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final padding = MediaQuery.paddingOf(context);

    final paddingAbove = padding.top + _kToolbarScreenPadding;
    final Offset localAdjustment = Offset(_kToolbarScreenPadding, paddingAbove);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _kToolbarScreenPadding,
        paddingAbove,
        _kToolbarScreenPadding,
        _kToolbarScreenPadding,
      ),
      child: CustomSingleChildLayout(
        delegate: DesktopTextSelectionToolbarLayoutDelegate(
          anchor: anchor - localAdjustment,
        ),
        child: _defaultToolbarBuilder(
          context,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _DesktopTextSelectionToolbarButton extends StatelessWidget {
  /// Creates an instance of DesktopTextSelectionToolbarButton.
  const _DesktopTextSelectionToolbarButton({
    required this.onPressed,
    required this.child,
  });

  /// Create an instance of [_DesktopTextSelectionToolbarButton] whose child is
  /// a [Text] widget in the style of the Material text selection toolbar.
  _DesktopTextSelectionToolbarButton.text({
    required BuildContext context,
    required this.onPressed,
    required String text,
  }) : child = Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: _kToolbarButtonFontStyle.copyWith(
            color: Theme.of(context).colorScheme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        );

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final primary = isDark ? Colors.white : Colors.black87;

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          enabledMouseCursor: SystemMouseCursors.basic,
          disabledMouseCursor: SystemMouseCursors.basic,
          foregroundColor: primary,
          shape: const RoundedRectangleBorder(),
          minimumSize: const Size(kMinInteractiveDimension, 45.0),
          padding: _kToolbarButtonPadding,
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
