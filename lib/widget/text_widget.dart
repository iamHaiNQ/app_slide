import 'package:flutter/material.dart';
import 'package:lap26_3/model/Slide.dart';
import 'package:lap26_3/utils/color_utils.dart';
import 'package:lap26_3/utils/html_parser.dart';
import 'package:lap26_3/utils/outline_painter.dart';
import 'package:lap26_3/utils/shape_clipper.dart';

class TextWidget extends StatefulWidget {
  final SlideElement element;
  final double scaleFactor;
  final double? width;
  final double? height;

  const TextWidget({
    super.key,
    required this.element,
    required this.scaleFactor,
    this.width,
    this.height,
  });

  @override
  State<TextWidget> createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;

        print('👉 HTML widget position: (${position.dx}, ${position.dy})');
        print('👉 HTML widget size: ${size.width} x ${size.height}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shadowData = widget.element.shadow;
    final List<Shadow> shadows = shadowData != null
        ? [
      Shadow(
        color: parseColor(shadowData['color']) ?? Colors.black,
        offset: Offset(
          (shadowData['h']?.toDouble() ?? 0),
          (shadowData['v']?.toDouble() ?? 0),
        ),
        blurRadius: shadowData['blur']?.toDouble() ?? 0.0,
      ),
    ]
        : [];

    final outlineData = widget.element.outline;
    final double strokeWidth = outlineData?['width']?.toDouble() ?? 0.0;
    final Color borderColor = parseColor(outlineData?['color'] ?? '#000000') ?? Colors.black;
    final bool isDashed = (outlineData?['style'] ?? 'solid') == 'dashed';

    final clipShape = ClipShape.rectangle;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Nền
                ClipPath(
                  clipper: ShapeClipper(clipShape),
                  child: Container(
                    color: parseColor(widget.element.fill ?? '#FFFFFF'),
                  ),
                ),

                // Text HTML (được clip và co giãn để vừa vùng)
                ClipPath(
                  clipper: ShapeClipper(clipShape),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: widget.width ?? constraints.maxWidth,
                        maxHeight: widget.height ?? constraints.maxHeight,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5), // Giảm padding
                      child: HtmlParser(
                        key: _textKey,
                        htmlContent: widget.element.content ?? '',
                        scaleFactor: widget.scaleFactor,
                        defaultFontName: widget.element.defaultFontName ?? 'Arial',
                        defaultColor: parseColor(widget.element.defaultColor ?? '#000000') ?? Colors.black,
                        wordSpacing: widget.element.wordSpace != null && widget.element.wordSpace!.isFinite
                            ? widget.element.wordSpace
                            : 0.0,
                        lineHeight: widget.element.lineHeight != null && widget.element.lineHeight!.isFinite
                            ? widget.element.lineHeight
                            : 1.2,
                        paragraphSpacing: widget.element.paragraphSpace != null && widget.element.paragraphSpace!.isFinite
                            ? widget.element.paragraphSpace
                            : 8.0,
                        shadows: shadows,
                      ),
                    ),
                  ),
                ),

                // Viền (nếu có)
                if (strokeWidth > 0)
                  CustomPaint(
                    painter: OutlinePainter(
                      color: borderColor,
                      strokeWidth: strokeWidth * widget.scaleFactor,
                      dashed: isDashed,
                      clipper: ShapeClipper(clipShape),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}