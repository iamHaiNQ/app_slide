// class ShapePainter extends CustomPainter {
//   final SlideElement element;
//
//   ShapePainter({required this.element});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Color(int.parse(element.fill!.replaceAll('#', '0xff')))
//           .withOpacity(element.opacity ?? 1.0)
//       ..style = PaintingStyle.fill;
//
//     final path = parseSvgPath(element.path!, size, element.viewBox!);
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
//
//   Path parseSvgPath(String svgPath, Size size, List<int> viewBox) {
//     final path = Path();
//     final commands = svgPath.split(RegExp(r'\s+'));
//     double x = 0,
//         y = 0;
//     final viewBoxWidth = viewBox[0].toDouble();
//     final viewBoxHeight = viewBox[1].toDouble();
//
//     for (int i = 0; i < commands.length; i++) {
//       switch (commands[i]) {
//         case 'M':
//           x = double.parse(commands[++i]) * size.width / viewBoxWidth;
//           y = double.parse(commands[++i]) * size.height / viewBoxHeight;
//           path.moveTo(x, y);
//           break;
//         case 'L':
//           x = double.parse(commands[++i]) * size.width / viewBoxWidth;
//           y = double.parse(commands[++i]) * size.height / viewBoxHeight;
//           path.lineTo(x, y);
//           break;
//         case 'C':
//           final x1 = double.parse(commands[++i]) * size.width / viewBoxWidth;
//           final y1 = double.parse(commands[++i]) * size.height / viewBoxHeight;
//           final x2 = double.parse(commands[++i]) * size.width / viewBoxWidth;
//           final y2 = double.parse(commands[++i]) * size.height / viewBoxHeight;
//           final x3 = double.parse(commands[++i]) * size.width / viewBoxWidth;
//           final y3 = double.parse(commands[++i]) * size.height / viewBoxHeight;
//           path.cubicTo(x1, y1, x2, y2, x3, y3);
//           x = x3;
//           y = y3;
//           break;
//         case 'Z':
//           path.close();
//           break;
//       }
//     }
//     return path;
//   }
// }
//
// class LinePainter extends CustomPainter {
//   final SlideElement element;
//
//   LinePainter({required this.element});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Color(int.parse(element.color!.replaceAll('#', '0xff')))
//       ..strokeWidth = element.width > 0 ? element.width : 1.0
//       ..style = PaintingStyle.stroke;
//
//     final start = Offset(element.start![0], element.start![1]);
//     final end = Offset(element.end![0], element.end![1]);
//
//     if (element.style == 'dashed') {
//       const dashWidth = 5.0;
//       const dashSpace = 5.0;
//       double distance = (end - start).distance;
//       double dx = end.dx - start.dx;
//       double dy = end.dy - start.dy;
//       double dashCount = distance / (dashWidth + dashSpace);
//       double stepX = dx / dashCount;
//       double stepY = dy / dashCount;
//
//       double currentX = start.dx;
//       double currentY = start.dy;
//       bool isDash = true;
//
//       for (int i = 0; i < dashCount; i++) {
//         if (isDash) {
//           final path = Path()
//             ..moveTo(currentX, currentY)
//             ..lineTo(currentX + stepX * (dashWidth / (dashWidth + dashSpace)),
//                 currentY + stepY * (dashWidth / (dashWidth + dashSpace)));
//           canvas.drawPath(path, paint);
//         }
//         currentX += stepX;
//         currentY += stepY;
//         isDash = !isDash;
//       }
//     } else {
//       final path = Path()
//         ..moveTo(start.dx, start.dy)
//         ..lineTo(end.dx, end.dy);
//       canvas.drawPath(path, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
