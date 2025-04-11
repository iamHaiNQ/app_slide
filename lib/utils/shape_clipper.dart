import 'dart:math';
import 'package:flutter/material.dart';

enum ClipShape {
  rectangle,
  cutTopRight,
  cutTopRightBottomLeft,
  square,
  roundedRectangle,
  ellipse,
  triangleUp,
  triangleDown,
  triangleLeft,
  diamond,
  pentagon,
  hexagon,
  heptagon,
  octagon,
  chevronRight,
  pointRight,
  rightArrow,
  parallelogram,
  trapezoidUp,
  trapezoidDown,
  trapezoidTall,
  trapezoidWide,
  parallelogramLeft,
}

class ShapeClipper extends CustomClipper<Path> {
  final ClipShape shape;
  final List<List<double>>? range; // Add range parameter

  ShapeClipper(this.shape, {this.range});

  @override
  Path getClip(Size size) {
    // Calculate range boundaries
    double startX = 0;
    double startY = 0;
    double endX = size.width;
    double endY = size.height;

    if (range != null && range!.length == 2) {
      startX = (range![0][0] / 100 * size.width).clamp(0, size.width);
      startY = (range![0][1] / 100 * size.height).clamp(0, size.height);
      endX = (range![1][0] / 100 * size.width).clamp(0, size.width);
      endY = (range![1][1] / 100 * size.height).clamp(0, size.height);
    }

    // Adjust size and offset based on range
    final clippedWidth = endX - startX;
    final clippedHeight = endY - startY;
    final clippedSize = Size(clippedWidth, clippedHeight);

    final path = Path();

    // Apply offset to all points
    void moveTo(double x, double y) => path.moveTo(startX + x, startY + y);
    void lineTo(double x, double y) => path.lineTo(startX + x, startY + y);

    switch (shape) {
      // Hinh chu nhat
      case ClipShape.rectangle:
        path.addRect(
            Rect.fromLTWH(startX, startY, clippedWidth, clippedHeight));
        break;
      // Hinh vuong
      case ClipShape.square:
        double dim = clippedSize.shortestSide;
        path.addRect(Rect.fromLTWH(startX, startY, dim, dim));
        break;
      // Hinh chu nhat co goc tron
      case ClipShape.roundedRectangle:
        path.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, startY, clippedWidth, clippedHeight),
          Radius.circular(10.0),
        ));
        break;
      // HCN cat 2 goc
      case ClipShape.cutTopRightBottomLeft:
        final double cutW = clippedWidth * 0.2;
        final double cutH = clippedHeight * 0.2;
        moveTo(0, 0);
        lineTo(clippedWidth - cutW, 0);
        lineTo(clippedWidth, cutH);
        lineTo(clippedWidth, clippedHeight);
        lineTo(cutW, clippedHeight);
        lineTo(0, clippedHeight - cutH);
        path.close();
        break;
      // HCN cat 1 goc tren phai
      case ClipShape.cutTopRight:
        final double cutW = clippedWidth * 0.2;
        final double cutH = clippedHeight * 0.2;
        moveTo(0, 0);
        lineTo(clippedWidth - cutW, 0);
        lineTo(clippedWidth, cutH);
        lineTo(clippedWidth, clippedHeight);
        lineTo(0, clippedHeight);
        path.close();
        break;

      // hinh tron
      case ClipShape.ellipse:
        path.addOval(
            Rect.fromLTWH(startX, startY, clippedWidth, clippedHeight));
        break;
      // Hinh tam giac 0
      case ClipShape.triangleUp:
        moveTo(clippedWidth / 2, 0);
        lineTo(0, clippedHeight);
        lineTo(clippedWidth, clippedHeight);
        path.close();
        break;
      // hinh tam giac xuong
      case ClipShape.triangleDown:
        moveTo(0, 0);
        lineTo(clippedWidth / 2, clippedHeight);
        lineTo(clippedWidth, 0);
        path.close();
        break;
      // hinh tam giac trai
      case ClipShape.triangleLeft:
        final double w = clippedWidth;
        final double h = clippedHeight;

        moveTo(0, 0);    // top-left
        lineTo(0, h);    // bottom-left
        lineTo(w, h);    // bottom-right
        path.close();
        break;
      // hinh thoi
      case ClipShape.diamond:
        moveTo(clippedWidth / 2, 0);
        lineTo(0, clippedHeight / 2);
        lineTo(clippedWidth / 2, clippedHeight);
        lineTo(clippedWidth, clippedHeight / 2);
        path.close();
        break;
      // hinh ngu giac
      case ClipShape.pentagon:
        final double w = clippedWidth;
        final double h = clippedHeight;
        moveTo(w * 0.5, 0);
        lineTo(0, h * 0.38);
        lineTo(w * 0.2, h);
        lineTo(w * 0.8, h);
        lineTo(w, h * 0.38);
        path.close();
        break;
      //hinh luc giac
      case ClipShape.hexagon:
        final double w = clippedWidth;
        final double h = clippedHeight;
        moveTo(w * 0.25, 0);
        lineTo(w * 0.75, 0);
        lineTo(w, h * 0.5);
        lineTo(w * 0.75, h);
        lineTo(w * 0.25, h);
        lineTo(0, h * 0.5);
        path.close();
        break;
      case ClipShape
            .heptagon: // Hình thất giác đều (regular heptagon) như trong ảnh
        final sides = 7;
        final double radiusX = clippedWidth / 2;
        final double radiusY = clippedHeight / 2;
        final angle = (2 * pi) / sides;
        final radius = clippedSize.shortestSide / 2;
        final center =
            Offset(startX + clippedWidth / 2, startY + clippedHeight / 2);

        // Bắt đầu từ điểm dưới cùng (để cạnh dưới nằm ngang)
        for (int i = 0; i < sides; i++) {
          final x = center.dx + radiusX * cos(angle * i - pi / 2);
          final y = center.dy + radiusY * sin(angle * i - pi / 2);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        break;

      case ClipShape.octagon: // Hình bát giác với cạnh trên và dưới bằng nhau
        final double w = clippedWidth;
        final double h = clippedHeight;
        // Tính độ dài cạnh trên và dưới (40% chiều rộng)
        final double topBottomEdge = w * 0.4;
        // Tính độ dài cạnh trái và phải (40% chiều cao)
        final double leftRightEdge = h * 0.4;
        // Tính khoảng cách từ mép để đặt cạnh trên và dưới
        final double xOffset = (w - topBottomEdge) / 2; // 30% mỗi bên
        final double yOffset = (h - leftRightEdge) / 2; // 30% mỗi bên

        moveTo(xOffset, 0); // Điểm trên cùng, lệch trái
        lineTo(xOffset + topBottomEdge, 0); // Điểm trên cùng, lệch phải
        lineTo(w, yOffset); // Điểm phải trên
        lineTo(w, yOffset + leftRightEdge); // Điểm phải dưới
        lineTo(xOffset + topBottomEdge, h); // Điểm dưới cùng, lệch phải
        lineTo(xOffset, h); // Điểm dưới cùng, lệch trái
        lineTo(0, yOffset + leftRightEdge); // Điểm trái dưới
        lineTo(0, yOffset); // Điểm trái trên
        path.close();
        break;
      // hinh arrow
      case ClipShape.chevronRight:
        moveTo(0, 0);
        lineTo(clippedWidth * 0.75, 0);
        lineTo(clippedWidth, clippedHeight / 2);
        lineTo(clippedWidth * 0.75, clippedHeight);
        lineTo(0, clippedHeight);
        lineTo(clippedWidth * 0.25, clippedHeight / 2);
        path.close();
        break;
      // hinh thang len
      case ClipShape.trapezoidUp:
        moveTo(clippedWidth * 0.2, 0);
        lineTo(clippedWidth * 0.8, 0);
        lineTo(clippedWidth, clippedHeight);
        lineTo(0, clippedHeight);
        path.close();
        break;
      // hinh thang xuong
      case ClipShape.trapezoidDown:
        moveTo(0, 0);
        lineTo(clippedWidth, 0);
        lineTo(clippedWidth * 0.8, clippedHeight);
        lineTo(clippedWidth * 0.2, clippedHeight);
        path.close();
        break;
      case ClipShape.trapezoidTall:
        moveTo(clippedWidth * 0.3, 0);
        lineTo(clippedWidth * 0.7, 0);
        lineTo(clippedWidth, clippedHeight);
        lineTo(0, clippedHeight);
        path.close();
        break;
      case ClipShape.trapezoidWide:
        moveTo(clippedWidth * 0.15, 0);
        lineTo(clippedWidth * 0.85, 0);
        lineTo(clippedWidth, clippedHeight);
        lineTo(0, clippedHeight);
        path.close();
        break;
      // hinh chevron sang phải

      case ClipShape.pointRight:
        final double w = clippedWidth;
        final double h = clippedHeight;
        final double pointerWidth = w * 0.2;

        moveTo(0, 0); // top-left
        lineTo(w - pointerWidth, 0); // top-right before point
        lineTo(w, h / 2); // point tip (right center)
        lineTo(w - pointerWidth, h); // bottom-right before point
        lineTo(0, h); // bottom-left
        path.close();
        break;

      case ClipShape.rightArrow:
        final double w = clippedWidth;
        final double h = clippedHeight;

        final double arrowHeadWidth = w * 0.4;
        final double bodyHeight = h * 0.7;
        final double bodyTop = (h - bodyHeight) / 2;
        final double bodyBottom = bodyTop + bodyHeight;

        moveTo(0, bodyTop);                          // Start top-left of body
        lineTo(w - arrowHeadWidth, bodyTop);         // Top-right before arrow
        lineTo(w - arrowHeadWidth, 0);               // Go to top of arrow
        lineTo(w, h / 2);                            // Arrow tip
        lineTo(w - arrowHeadWidth, h);               // Bottom of arrow
        lineTo(w - arrowHeadWidth, bodyBottom);      // Bottom-right of body
        lineTo(0, bodyBottom);                       // Back to bottom-left
        path.close();

      // hinh binh hanh 0
      case ClipShape.parallelogram:
        final double w = clippedWidth;
        final double h = clippedHeight;
        final double slant = w * 0.4; // 20% nghiêng

        moveTo(slant, 0); // top-left (lùi vào 20%)
        lineTo(w, 0); // top-right
        lineTo(w - slant, h); // bottom-right (cũng lùi vào 20%)
        lineTo(0, h); // bottom-left
        path.close();
        break;
      // hình parallelogram 2
      case ClipShape.parallelogramLeft:
        final double w = clippedWidth;
        final double h = clippedHeight;
        final double slant = w * 0.4; // độ nghiêng (20% chiều rộng)

        moveTo(0, 0);       // top-left (lùi vào)
        lineTo(w - slant, 0);     // top-right
        lineTo(w, h);             // bottom-right
        lineTo(slant, w - slant);            // bottom-left
        path.close();
        break;
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;

  Path _createStarPath(Size size, int points, double offsetX, double offsetY) {
    final path = Path();
    final double outerRadius = size.shortestSide / 2;
    final double innerRadius = outerRadius / 2.5;
    final double centerX = size.width / 2 + offsetX;
    final double centerY = size.height / 2 + offsetY;
    final double angle = pi / points;

    for (int i = 0; i < points * 2; i++) {
      double r = i.isEven ? outerRadius : innerRadius;
      double x = centerX + r * cos(i * angle - pi / 2);
      double y = centerY + r * sin(i * angle - pi / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }
}
