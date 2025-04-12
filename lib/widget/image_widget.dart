
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lap26_3/model/Slide.dart';
import 'package:lap26_3/utils/outline_painter.dart';
import 'package:lap26_3/utils/color_utils.dart';
import 'package:lap26_3/utils/shadow_painter.dart';
import 'package:lap26_3/utils/shape_clipper.dart';

class ImageElementWidget extends StatelessWidget {
  final SlideElement element;
  final double width;
  final double height;

  const ImageElementWidget({
    super.key,
    required this.element,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = element.src != null
        ? Image.network(
            element.src!,
            fit: BoxFit.cover,
            width: width,
            height: height,
            color: element.colorMask != null
                ? parseColor(element.colorMask!)
                : null,
            colorBlendMode:
                element.colorMask != null ? BlendMode.srcATop : null,
          )
        : const SizedBox.shrink();

    // Clip shape (Áp dụng trước các thuộc tính khác)
    CustomClipper<Path>? clipper;
    if (element.clip != null && element.clip!.containsKey('shape') && element.clip!['shape'] != null) {
      clipper = _getCustomClipper(element.clip!);
      image = ClipPath(
        clipper: clipper,
        child: image,
      );
    }

    // Flip H/V (Áp dụng sau khi cắt)
    if (element.flipH == true || element.flipV == true) {
      image = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(element.flipH == true ? -1.0 : 1.0,
              element.flipV == true ? -1.0 : 1.0),
        child: image,
      );
    }

    // Filter (e.g., grayscale, hue) (Áp dụng sau khi cắt)
    if (element.filters != null) {
      print('filters: ${element.filters}');
      final blur = _parseBlur(element.filters!);
      if (blur != null) {
        image = ImageFiltered(
          imageFilter: blur,
          child: image,
        );
      }
    }

    if (element.filters != null) {
      image = ColorFiltered(
        colorFilter: _parseColorMatrix(element.filters!),
        child: image,
      );
    }

    // Shadow (Áp dụng sau khi cắt)
    if (element.clip != null && element.clip!['shape'] != null) {
      final clipper = _getCustomClipper(element.clip!);
      final path = clipper.getClip(Size(width, height));

      // Nếu có shadow thì vẽ bóng theo clip path
      if (element.shadow != null) {
        final shadowColor = parseColor(element.shadow!['color'] ?? '#000000');
        final blur = element.shadow!['blur']?.toDouble() ?? 0;
        final dx = element.shadow!['h']?.toDouble() ?? 0;
        final dy = element.shadow!['v']?.toDouble() ?? 0;

        image = Stack(
          children: [
            CustomPaint(
              size: Size(width, height),
              painter: ClipShadowPainter(
                clipPath: path,
                color: shadowColor,
                blur: blur,
                offset: Offset(dx, dy),
              ),
            ),
            ClipPath(
              clipper: clipper,
              child: image,
            ),
          ],
        );
      } else {
        // Không có shadow nhưng vẫn cần clip
        image = ClipPath(
          clipper: clipper,
          child: image,
        );
      }
    } else {
      // Nếu không có clip, dùng shadow kiểu mặc định (hình chữ nhật)
      if (element.shadow != null) {
        image = Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: parseColor(element.shadow!['color'] ?? '#000000'),
              blurRadius: element.shadow!['blur']?.toDouble() ?? 0,
              offset: Offset(
                element.shadow!['h']?.toDouble() ?? 0,
                element.shadow!['v']?.toDouble() ?? 0,
              ),
            )
          ]),
          child: image,
        );
      }
    }

    // Outline (Áp dụng sau khi cắt)
    if (element.outline != null ) {
      clipper ??= ShapeClipper(ClipShape.rectangle);
      final style = element.outline!['style']?.toLowerCase();
      final outlineStyle = (style == 'dashed') ? 'dashed' : 'solid';
      print('Outline style: $style');
      print('Element Outline: ${element.outline}');// In ra kiểu outline để kiểm tra)

      image = Stack(
        children: [
          ClipPath(
            clipper: clipper,
            child: image,
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: OutlinePainter(
                clipper: clipper,
                color: parseColor(element.outline!['color'] ?? '#000'),
                strokeWidth: (element.outline!['width'] ?? 1).toDouble(),
                dashed: element.outline!['style'] == 'dashed',
              ),
            ),
          ),
        ],
      );
    }
    return image;
  }
}

// Shape clipper
CustomClipper<Path> _getCustomClipper(Map<String, dynamic> clipData) {
  // Lấy range từ clipData và chuyển đổi thành List<List<double>>
  final rawRange = clipData['range'] as List<dynamic>?;
  List<List<double>>? parsedRange;

  if (rawRange != null) {
    parsedRange = rawRange
        .map<List<double>>((point) => (point as List<dynamic>)
            .map<double>((val) => val.toDouble())
            .toList())
        .toList();
  }

  // Lấy tên hình dạng từ clipData
  String shapeStr = (clipData['shape'] as String?)?.toLowerCase() ??
      'rect'; // Mặc định là rectangle nếu không có
  ClipShape clipShape;
  print('shape: $shapeStr'); // Ánh xạ chuỗi shape từ JSON sang ClipShape
  switch (shapeStr) {
    case 'rect':
      clipShape = ClipShape.rectangle;
      break;
    case 'rect2':
      clipShape = ClipShape.cutTopRight;
      break;
    case 'rect3':
      clipShape = ClipShape.cutTopRightBottomLeft;
      break;
    case 'roundrect':
      clipShape = ClipShape.roundedRectangle;
      break;
    case 'ellipse':
      clipShape = ClipShape.ellipse;
      break;
    case 'triangle':
      clipShape = ClipShape.triangleUp;
      break;
    case 'triangle2':
      clipShape = ClipShape.triangleDown;
      break;
    case 'triangle3':
      clipShape = ClipShape.triangleLeft;
      break;
    case 'rhombus':
      clipShape = ClipShape.diamond;
      break;
    case 'pentagon':
      clipShape = ClipShape.pentagon;
      break;
    case 'hexagon':
      clipShape = ClipShape.hexagon;
      break;
    case 'heptagon':
      clipShape = ClipShape.heptagon;
      break;
    case 'octagon':
      clipShape = ClipShape.octagon;
      break;
    case 'chevron':
      clipShape = ClipShape.chevronRight;
      break;
    case 'point':
      clipShape = ClipShape.pointRight;
      break;
    case 'parallelogram2':
      clipShape = ClipShape.parallelogramLeft;
      ;
      break;
    case 'arrow':
      clipShape = ClipShape.rightArrow;
      break;
    case 'trapezoid':
      clipShape = ClipShape.trapezoidUp;
      break;
    case 'trapezoid2':
      clipShape = ClipShape.trapezoidDown;
      break;
    case 'parallelogram':
      clipShape = ClipShape.parallelogram;
      break;
    default:
      clipShape = ClipShape.rectangle; // Hình mặc định nếu không khớp
      break;
  }

  // Trả về ShapeClipper với hình dạng và range đã xử lý
  return ShapeClipper(clipShape, range: parsedRange);
}

// CSS-like filters
ImageFilter? _parseBlur(Map<String, String> filters) {
  final blur = filters['blur'];
  if (blur != null && blur.endsWith('px')) {
    final value = double.tryParse(blur.replaceAll('px', '')) ?? 0;
    return ImageFilter.blur(sigmaX: value, sigmaY: value);
  }
  return null;
}

double _safeParsePercent(String? value, {double defaultValue = 0}) {
  final parsed = double.tryParse(value?.replaceAll('%', '') ?? '');
  return parsed != null ? parsed / 100 : defaultValue;
}

double _safeParseDegree(String? value, {double defaultValue = 0}) {
  final parsed = double.tryParse(value?.replaceAll('deg', '') ?? '');
  return parsed ?? defaultValue;
}

ColorFilter _parseColorMatrix(Map<String, String> filters) {
  double grayscale = _safeParsePercent(filters['grayscale'], defaultValue: 0.0).clamp(0.0, 1.0);
  double brightness = _safeParsePercent(filters['brightness'], defaultValue: 1.0);
  double contrast = _safeParsePercent(filters['contrast'], defaultValue: 1.0);
  double saturate = _safeParsePercent(filters['saturate'], defaultValue: 1.0);
  double hueRotate = _safeParseDegree(filters['hue-rotate'], defaultValue: 0.0);

  final radians = hueRotate * pi / 180;
  final cosVal = cos(radians);
  final sinVal = sin(radians);

  const lumR = 0.213;
  const lumG = 0.715;
  const lumB = 0.072;

  final hueMatrix = [
    lumR + cosVal * (1 - lumR) + sinVal * (-lumR),
    lumG + cosVal * (-lumG) + sinVal * (-lumG),
    lumB + cosVal * (-lumB) + sinVal * (1 - lumB),
    0.0,
    0.0,
    lumR + cosVal * (-lumR) + sinVal * (0.143),
    lumG + cosVal * (1 - lumG) + sinVal * (0.14),
    lumB + cosVal * (-lumB) + sinVal * (-0.283),
    0.0,
    0.0,
    lumR + cosVal * (-lumR) + sinVal * (-(1 - lumR)),
    lumG + cosVal * (-lumG) + sinVal * (lumG),
    lumB + cosVal * (1 - lumB) + sinVal * (lumB),
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0
  ];

  final colorMatrix = List<double>.from(hueMatrix);
  if (grayscale > 0) {
    for (int i = 0; i < colorMatrix.length; i += 5) {
      final r = colorMatrix[i];
      final g = colorMatrix[i + 1];
      final b = colorMatrix[i + 2];
      colorMatrix[i] = r * (1 - grayscale) + grayscale * lumR;
      colorMatrix[i + 1] = g * (1 - grayscale) + grayscale * lumG;
      colorMatrix[i + 2] = b * (1 - grayscale) + grayscale * lumB;
    }
  }
  for (int i = 0; i < colorMatrix.length; i += 5) {
    colorMatrix[i] *= saturate * contrast * brightness;
    colorMatrix[i + 1] *= saturate * contrast * brightness;
    colorMatrix[i + 2] *= saturate * contrast * brightness;
  }

  return ColorFilter.matrix(colorMatrix);
}


