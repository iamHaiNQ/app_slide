import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' as html;
import '../model/Slide.dart';
import '../utils/color_utils.dart';
import '../utils/html_parser.dart';

class TextWidget extends StatelessWidget {
  final SlideElement element;
  final double width;
  final double height;
  final double scaleFactor;

  const TextWidget({
    super.key,
    required this.element,
    required this.width,
    required this.height,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final parser = HtmlParser.fromHtml(element.content ?? '');
    final boxDecoration = BoxDecoration(
      border: Border.all(
        color: element.outline != null
            ? parseColor(element.outline!['color'])
            : Colors.transparent,
        width: element.outline != null ? element.outline!['width'] ?? 0.0 : 0.0,
      ),
      borderRadius: BorderRadius.circular(4),
      boxShadow: element.shadow != null
          ? [
        BoxShadow(
          color: parseColor(element.shadow!['color']),
          blurRadius:
          (element.shadow!['blur'] as num?)?.toDouble() ?? 0.0,
          offset: Offset(
            (element.shadow!['h'] as num?)?.toDouble() ?? 0.0,
            (element.shadow!['v'] as num?)?.toDouble() ?? 0.0,
          ),
        ),
      ]
          : null,
    );

    final padding = EdgeInsets.all(element.paragraphSpace ?? 0.0);

    TextStyle buildTextStyle(TextElement textElement, String fallbackFontSize) {
      return TextStyle(
        color: parseColor(
            textElement.color ?? element.defaultColor ?? "#000000"),
        fontSize: _getScaledFontSize(
          textElement.fontSize.isNotEmpty
              ? textElement.fontSize
              : fallbackFontSize,
          scaleFactor,
        ),
        fontFamily: textElement.fontFamily.isNotEmpty
            ? GoogleFonts.getFont(textElement.fontFamily).fontFamily
            : element.defaultFontName,
        fontWeight: textElement.isBold ? FontWeight.bold : null,
        fontStyle: textElement.isItalic ? FontStyle.italic : null,
        decoration: TextDecoration.combine([
          if (textElement.isStrikethrough) TextDecoration.lineThrough,
          if (textElement.isUnderline) TextDecoration.underline,
        ]),
        height: element.lineHeight?.isFinite == true ? element.lineHeight : 1.0,
        wordSpacing: (element.wordSpace ?? 1.0).toDouble(),
      );
    }

    TextAlign _parseTextAlign(String? align) {
      switch (align?.toLowerCase()) {
        case 'left':
          return TextAlign.left;
        case 'center':
          return TextAlign.center;
        case 'right':
          return TextAlign.right;
        case 'justify':
          return TextAlign.justify;
        case 'start':
          return TextAlign.start;
        case 'end':
          return TextAlign.end;
        default:
          return TextAlign.left;
      }
    }

    if (parser.items.isEmpty && element.content != null) {
      final document = html.parse(element.content!);
      final textElement = TextElement();
      if (document.body != null) {
        textElement.parseElement(document.body!);
        return Container(
          width: width,
          height: height,
          decoration: boxDecoration,
          padding: padding,
          child: SingleChildScrollView(
            child: Text(
              textElement.text,
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: null,
              textAlign: _parseTextAlign(textElement.textAlign),
              style: buildTextStyle(textElement, '16px'),
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    return Container(
      width: width,
      height: height,
      decoration: boxDecoration,
      padding: padding,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: parser.items.map((listItem) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: getBulletWidget(
                      parser.listType,
                      _getScaledFontSize(parser.listFontSize, scaleFactor),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: listItem.texts.map((textElement) {
                        return Text(
                          textElement.text,
                          textAlign: _parseTextAlign(textElement.textAlign),
                          style: buildTextStyle(
                              textElement, parser.listFontSize),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  double _getScaledFontSize(String fontSizeStr, double scaleFactor) {
    final baseSize = double.tryParse(fontSizeStr.replaceAll('px', '')) ?? 16;
    return baseSize * scaleFactor;
  }

  Widget getBulletWidget(String listType, double fontSize) {
    switch (listType.toLowerCase()) {
      case 'disc':
        return Container(
          width: fontSize / 2,
          height: fontSize / 2,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        );
      case 'circle':
        return Container(
          width: fontSize / 2,
          height: fontSize / 2,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            shape: BoxShape.circle,
          ),
        );
      case 'square':
        return Container(
          width: fontSize / 2,
          height: fontSize / 2,
          margin: const EdgeInsets.only(top: 6),
          color: Colors.black,
        );
      case 'decimal':
        return Text(
          '1.',
          style: TextStyle(fontSize: fontSize),
        );
      default:
        return Container(
          width: fontSize / 2,
          height: fontSize / 2,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        );
    }
  }
}
