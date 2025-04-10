import 'package:flutter/material.dart';
import 'dart:ui';

class ShapePainter extends CustomPainter {
  const ShapePainter({
    required this.path,
    required this.fillColor,
    required this.opacity,
    required this.flipV,
    this.viewBoxWidth = 1024,
    this.viewBoxHeight = 1024,
  });

  final String path;
  final Color fillColor;
  final double opacity;
  final bool flipV;
  final double viewBoxWidth;
  final double viewBoxHeight;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = fillColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    Path path = parseSvgPath(this.path, size, flipV, viewBoxWidth, viewBoxHeight);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// Hàm phân tích và vẽ SVG Path
Path parseSvgPath(String pathStr, Size size, bool flipV, double viewBoxWidth, double viewBoxHeight) {
  Path path = Path();
  final RegExp regex = RegExp(r"([a-zA-Z])|([-+]?\d*\.?\d+)");
  final List<String> tokens = regex.allMatches(pathStr).map((m) => m.group(0)!).toList();

  double scaleX = size.width / viewBoxWidth;
  double scaleY = size.height / viewBoxHeight;

  double lastX = 0, lastY = 0;
  double startX = 0, startY = 0;
  int i = 0;

  while (i < tokens.length) {
    String command = tokens[i];

    if (command == "M" || command == "m") {
      bool relative = command == "m";
      double x = double.parse(tokens[++i]) * scaleX + (relative ? lastX : 0);
      double y = double.parse(tokens[++i]) * scaleY + (relative ? lastY : 0);
      y = flipV ? size.height - y : y;
      path.moveTo(x, y);
      lastX = startX = x;
      lastY = startY = y;
    }
    else if (command == "L" || command == "l") {
      bool relative = command == "l";
      double x = double.parse(tokens[++i]) * scaleX + (relative ? lastX : 0);
      double y = double.parse(tokens[++i]) * scaleY + (relative ? lastY : 0);
      y = flipV ? size.height - y : y;
      path.lineTo(x, y);
      lastX = x;
      lastY = y;
    }
    else if (command == "C" || command == "c") {
      bool relative = command == "c";
      double x1 = double.parse(tokens[++i]) * scaleX + (relative ? lastX : 0);
      double y1 = double.parse(tokens[++i]) * scaleY + (relative ? lastY : 0);
      double x2 = double.parse(tokens[++i]) * scaleX + (relative ? lastX : 0);
      double y2 = double.parse(tokens[++i]) * scaleY + (relative ? lastY : 0);
      double x = double.parse(tokens[++i]) * scaleX + (relative ? lastX : 0);
      double y = double.parse(tokens[++i]) * scaleY + (relative ? lastY : 0);

      if (flipV) {
        y1 = size.height - y1;
        y2 = size.height - y2;
        y = size.height - y;
      }

      path.cubicTo(x1, y1, x2, y2, x, y);
      lastX = x;
      lastY = y;
    }
    else if (command == "V" || command == "v") {
      bool relative = command == "v";
      double y = double.parse(tokens[++i]) * scaleY + (relative ? lastY : 0);
      y = flipV ? size.height - y : y;
      path.lineTo(lastX, y);
      lastY = y;
    }
    else if (command == "H" || command == "h") {
      bool relative = command == "h";
      double x = double.parse(tokens[++i]) * scaleX + (relative ? lastX : 0);
      path.lineTo(x, lastY);
      lastX = x;
    }
    else if (command == "A" || command == "a") {
      // Lệnh A (arc) rất phức tạp, cần thêm xử lý riêng
    }
    else if (command == "Z" || command == "z") {
      path.close();
      lastX = startX;
      lastY = startY;
    }
    i++;
  }

  return path;
}
