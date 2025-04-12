import 'package:flutter/material.dart';

class OutlinePainter extends CustomPainter {
  final CustomClipper<Path> clipper;
  final Color color;
  final double strokeWidth;
  final bool dashed;

  OutlinePainter({
    required this.clipper,
    required this.color,
    required this.strokeWidth,
    this.dashed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = clipper.getClip(size);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    if (dashed) {
      _drawDashedPath(canvas, path, paint,strokeWidth);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path originalPath, Paint paint, double width) {
    final dashLength = width * 4.5;
    final gapLength = width * 1.1;

    for (final metric in originalPath.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        final pathSegment = metric.extractPath(distance, next.clamp(0, metric.length));
        canvas.drawPath(pathSegment, paint);
        distance += dashLength + gapLength;
      }
    }
  }


  @override
  bool shouldRepaint(covariant OutlinePainter oldDelegate) => true;
}
