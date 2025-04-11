import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lap26_3/model/Slide.dart';
import 'package:lap26_3/utils/color_utils.dart';
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
    if (element.clip != null && element.clip!['shape'] != null) {
      image = ClipPath(
        clipper: _getCustomClipper(element.clip!),
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
      image = ColorFiltered(
        colorFilter: _parseFilters(element.filters!),
        child: image,
      );
    }

    // Shadow (Áp dụng sau khi cắt)
    if (element.shadow != null) {
      image = Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: parseColor(element.shadow!['color'] ?? '#000000'),
            blurRadius: element.shadow!['blur'] ?? 0,
            offset: Offset(
              element.shadow!['h']?.toDouble() ?? 0,
              element.shadow!['v']?.toDouble() ?? 0,
            ),
          )
        ]),
        child: image,
      );
    }

    // Outline (Áp dụng sau khi cắt)
    if (element.outline != null) {
      image = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: parseColor(element.outline!['color'] ?? '#000'),
            width: element.outline!['width']?.toDouble() ?? 1,
            style: BorderStyle.solid,
          ),
        ),
        child: image,
      );
    }

    return image;
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
    print('shape: $shapeStr');    // Ánh xạ chuỗi shape từ JSON sang ClipShape
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
  ColorFilter _parseFilters(Map<String, String> filters) {
    double grayscale =
        double.tryParse(filters['grayscale']?.replaceAll('%', '') ?? '0') ?? 0;
    grayscale = grayscale.clamp(0, 100) / 100;

    // Basic grayscale filter
    return ColorFilter.matrix(<double>[
      0.2126 + 0.7874 * (1 - grayscale),
      0.7152 - 0.7152 * grayscale,
      0.0722 - 0.0722 * grayscale,
      0,
      0,
      //
      0.2126 - 0.2126 * grayscale,
      0.7152 + 0.2848 * (1 - grayscale),
      0.0722 - 0.0722 * grayscale,
      0,
      0,
      //
      0.2126 - 0.2126 * grayscale,
      0.7152 - 0.7152 * grayscale,
      0.0722 + 0.9278 * (1 - grayscale),
      0,
      0,
      //
      0,
      0,
      0,
      1,
      0
    ]);
  }
}
