import 'package:flutter/widgets.dart';

class CurvedLinePainter extends CustomPainter {
  final bool isLast;
  final EdgeInsets padding;
  final Size avatarRoot;
  final Size avatarChild;
  final Color pathColor;
  final double strokeWidth;

  CurvedLinePainter({
    required this.isLast,
    required this.padding,
    required this.avatarRoot,
    required this.avatarChild,
    required this.pathColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(avatarRoot.width / 2, 0)
      ..cubicTo(
        avatarRoot.width / 2,
        0,
        avatarRoot.width / 2,
        padding.top + avatarChild.height / 2,
        avatarRoot.width,
        padding.top + avatarChild.height / 2,
      );

    canvas.drawPath(path, paint);

    if (!isLast) {
      canvas.drawLine(
        Offset(avatarRoot.width / 2, 0),
        Offset(avatarRoot.width / 2, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
