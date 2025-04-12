import 'package:flutter/cupertino.dart';

class ClipShadowPainter extends CustomPainter {
  final Path clipPath;
  final Color color;
  final double blur;
  final Offset offset;

  ClipShadowPainter({
    required this.clipPath,
    required this.color,
    required this.blur,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(1.0)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawPath(clipPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
