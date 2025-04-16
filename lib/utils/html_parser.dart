import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:google_fonts/google_fonts.dart';

import 'color_utils.dart';

// Hàm tiện ích để chuyển đổi font-size, word-spacing, line-height từ px thành double
double? parseLength(String? length) {
  if (length == null) return null;
  final value = double.tryParse(length.replaceAll('px', '')) ?? double.tryParse(length);
  return value != null && value.isFinite ? value : null;
}

// Hàm tiện ích để chuyển đổi line-height thành giá trị hợp lý
double? parseLineHeight(String? lineHeight, double? fontSize) {
  if (lineHeight == null || fontSize == null || !fontSize.isFinite) return null;
  final value = parseLength(lineHeight);
  if (value != null && value.isFinite) {
    return value;
  } else {
    final relative = double.tryParse(lineHeight);
    return relative != null && relative.isFinite ? fontSize * relative : null;
  }
}

// Hàm ánh xạ fontName sang Google Fonts
// Hàm ánh xạ fontName sang Google Fonts
TextStyle getGoogleFontStyle(String? fontName, TextStyle baseStyle) {
  // Nếu fontName là null, trả về Roboto làm mặc định
  if (fontName == null) {
    print('Debug: fontName is null, using default Roboto');
    return GoogleFonts.roboto(textStyle: baseStyle);
  }

  // Chuẩn hóa fontName: loại bỏ khoảng trắng và chuyển thành chữ thường
  final normalizedFontName = fontName.replaceAll(' ', '').toLowerCase().trim();
  print('Debug: Normalized fontName: $normalizedFontName');

  // Ánh xạ các font phổ biến từ HTML sang Google Fonts
  switch (normalizedFontName) {
    case 'arial':
    case 'helvetica':
      print('Debug: Mapping $normalizedFontName to Arimo');
      return GoogleFonts.arimo(textStyle: baseStyle);
    case 'timesnewroman':
    case 'times':
      print('Debug: Mapping $normalizedFontName to Merriweather');
      return GoogleFonts.merriweather(textStyle: baseStyle);
    case 'roboto':
      print('Debug: Mapping $normalizedFontName to Roboto');
      return GoogleFonts.roboto(textStyle: baseStyle);
    case 'lato':
      print('Debug: Mapping $normalizedFontName to Lato');
      return GoogleFonts.lato(textStyle: baseStyle);
    case 'opensans':
      print('Debug: Mapping $normalizedFontName to Open Sans');
      return GoogleFonts.openSans(textStyle: baseStyle);
    case 'georgia':
      print('Debug: Mapping $normalizedFontName to Lora');
      return GoogleFonts.lora(textStyle: baseStyle);
    case 'verdana':
      print('Debug: Mapping $normalizedFontName to Source Sans Pro');
      return GoogleFonts.sourceSans3(textStyle: baseStyle);
    case 'courier':
    case 'couriernew':
      print('Debug: Mapping $normalizedFontName to Source Code Pro');
      return GoogleFonts.sourceCodePro(textStyle: baseStyle);
    case 'montserrat':
      print('Debug: Mapping $normalizedFontName to Montserrat');
      return GoogleFonts.montserrat(textStyle: baseStyle);
    case 'poppins':
      print('Debug: Mapping $normalizedFontName to Poppins');
      return GoogleFonts.poppins(textStyle: baseStyle);
    default:
      print('Debug: Font "$normalizedFontName" không được hỗ trợ, fallback to Roboto');
      return GoogleFonts.roboto(textStyle: baseStyle);
  }
}

// Lớp để biểu diễn một mục đã được parse (danh sách hoặc đoạn văn)
class ParsedItem {
  final String text;
  final bool isUnderlined;
  final bool isStrikethrough;
  final double? fontSize;
  final Color? color;
  final String? fontName;
  final double? wordSpacing;
  final double? lineHeight;
  final double? paragraphSpacing;
  final String? link;
  final String? linkTitle;
  final TextAlign textAlign;
  final bool isListItem;
  final List<Shadow>? shadows; // Thêm thuộc tính shadows

  ParsedItem({
    required this.text,
    this.isUnderlined = false,
    this.isStrikethrough = false,
    this.fontSize,
    this.color,
    this.fontName,
    this.wordSpacing,
    this.lineHeight,
    this.paragraphSpacing,
    this.link,
    this.linkTitle,
    this.textAlign = TextAlign.left,
    this.isListItem = false,
    this.shadows,
  });

  // Hàm để in giá trị của ParsedItem để debug
  void debugPrint(int index) {
    print('ParsedItem #$index:');
    print('  text: $text');
    print('  isUnderlined: $isUnderlined');
    print('  isStrikethrough: $isStrikethrough');
    print('  fontSize: $fontSize');
    print('  color: $color');
    print('  fontName: $fontName');
    print('  wordSpacing: $wordSpacing');
    print('  lineHeight: $lineHeight');
    print('  paragraphSpacing: $paragraphSpacing');
    print('  link: $link');
    print('  linkTitle: $linkTitle');
    print('  textAlign: $textAlign');
    print('  isListItem: $isListItem');
    print('  shadows: $shadows');
    print('---');
  }
}

// Widget hiển thị nội dung đã parse
class HtmlParser extends StatelessWidget {
  final String htmlContent;
  final String? defaultFontName;
  final Color? defaultColor;
  final double? wordSpacing;
  final double? lineHeight;
  final double? paragraphSpacing;
  final double scaleFactor;
  final List<Shadow>? shadows; // Thêm tham số shadows

  const HtmlParser({
    Key? key,
    required this.htmlContent,
    this.defaultFontName,
    this.defaultColor,
    this.wordSpacing,
    this.lineHeight,
    this.paragraphSpacing,
    required this.scaleFactor,
    this.shadows,
  }) : super(key: key);

  // Hàm parse HTML và trả về danh sách các ParsedItem
  List<ParsedItem> _parseHtml() {
    final document = parse(htmlContent);
    final items = <ParsedItem>[];

    print('Debug: Bắt đầu parse HTML...');

    // Kiểm tra xem có thẻ <ul> hay không
    final ulTag = document.querySelector('ul');
    if (ulTag != null) {
      print('Debug: Tìm thấy thẻ <ul>');
      // Xử lý danh sách <ul>
      double? ulFontSize;
      Color? ulColor;
      String? ulFontName;
      double? ulWordSpacing;
      double? ulLineHeight;
      double? ulParagraphSpacing;
      final ulStyle = ulTag.attributes['style']?.split(';') ?? [];
      print('Debug: Style của <ul>: $ulStyle');
      for (var style in ulStyle) {
        if (style.contains('font-size')) {
          ulFontSize = parseLength(style.split(':').last.trim());
          print('Debug: ulFontSize: $ulFontSize');
        }
        if (style.contains('color')) {
          ulColor = parseColor(style.split(':').last.trim());
          print('Debug: ulColor: $ulColor');
        }
        if (style.contains('font-family')) {
          ulFontName = style.split(':').last.trim().replaceAll('"', '');
          print('Debug: ulFontName: $ulFontName');
        }
        if (style.contains('word-spacing')) {
          ulWordSpacing = parseLength(style.split(':').last.trim());
          print('Debug: ulWordSpacing: $ulWordSpacing');
        }
        if (style.contains('line-height')) {
          ulLineHeight = parseLineHeight(style.split(':').last.trim(), ulFontSize);
          print('Debug: ulLineHeight: $ulLineHeight');
        }
        if (style.contains('margin-bottom') || style.contains('padding-bottom')) {
          ulParagraphSpacing = parseLength(style.split(':').last.trim());
          print('Debug: ulParagraphSpacing: $ulParagraphSpacing');
        }
      }

      // Tìm tất cả các thẻ <li> trong <ul>
      final listItems = ulTag.querySelectorAll('li');
      print('Debug: Số lượng thẻ <li>: ${listItems.length}');
      for (var li in listItems) {
        String text = '';
        bool isUnderlined = false;
        bool isStrikethrough = false;
        double? fontSize = ulFontSize != null ? ulFontSize * scaleFactor : null;
        Color? color = ulColor;
        String? fontName = ulFontName;
        double? wordSpacingItem = ulWordSpacing;
        double? lineHeightItem = ulLineHeight;
        double? paragraphSpacingItem = ulParagraphSpacing;
        String? link;
        String? linkTitle;
        TextAlign textAlign = TextAlign.left;

        // Xử lý thẻ <p> bên trong <li>
        final pTag = li.querySelector('p');
        if (pTag != null) {
          print('Debug: Tìm thấy thẻ <p> trong <li>');
          // Lấy style của <p>
          final pStyle = pTag.attributes['style']?.split(';') ?? [];
          print('Debug: Style của <p>: $pStyle');
          for (var style in pStyle) {
            if (style.contains('text-align')) {
              textAlign = style.contains('center') ? TextAlign.center : TextAlign.left;
              print('Debug: textAlign: $textAlign');
            }
            if (style.contains('font-size')) {
              fontSize = parseLength(style.split(':').last.trim());
              print('Debug: fontSize: $fontSize');
            }
            if (style.contains('color')) {
              color = parseColor(style.split(':').last.trim());
              print('Debug: color: $color');
            }
            if (style.contains('font-family')) {
              fontName = style.split(':').last.trim().replaceAll('"', '');
              print('Debug: fontName: $fontName');
            }
            if (style.contains('word-spacing')) {
              wordSpacingItem = parseLength(style.split(':').last.trim());
              print('Debug: wordSpacingItem: $wordSpacingItem');
            }
            if (style.contains('line-height')) {
              lineHeightItem = parseLineHeight(style.split(':').last.trim(), fontSize);
              print('Debug: lineHeightItem: $lineHeightItem');
            }
            if (style.contains('margin-bottom') || style.contains('padding-bottom')) {
              paragraphSpacingItem = parseLength(style.split(':').last.trim());
              print('Debug: paragraphSpacingItem: $paragraphSpacingItem');
            }
          }

          // Xử lý các thẻ con bên trong <p>
          void parseNode(dom.Node node) {
            if (node is dom.Text) {
              text += node.text.trim();
              print('Debug: Text node: ${node.text.trim()}');
            } else if (node is dom.Element) {
              if (node.localName == 'span') {
                final spanStyle = node.attributes['style']?.split(';') ?? [];
                print('Debug: Style của <span>: $spanStyle');
                for (var style in spanStyle) {
                  if (style.contains('text-decoration')) {
                    isUnderlined = style.contains('underline');
                    isStrikethrough = style.contains('line-through');
                    print('Debug: isUnderlined: $isUnderlined, isStrikethrough: $isStrikethrough');
                  }
                  if (style.contains('font-size')) {
                    fontSize = parseLength(style.split(':').last.trim());
                    print('Debug: fontSize (span): $fontSize');
                  }
                  if (style.contains('font-family')) {
                    fontName = style.split(':').last.trim().replaceAll('"', '');
                    print('Debug: fontName (span): $fontName');
                  }
                  if (style.contains('word-spacing')) {
                    wordSpacingItem = parseLength(style.split(':').last.trim());
                    print('Debug: wordSpacingItem (span): $wordSpacingItem');
                  }
                  if (style.contains('line-height')) {
                    lineHeightItem = parseLineHeight(style.split(':').last.trim(), fontSize);
                    print('Debug: lineHeightItem (span): $lineHeightItem');
                  }
                }
                node.nodes.forEach(parseNode);
              } else if (node.localName == 'a') {
                link = node.attributes['href'];
                linkTitle = node.attributes['title'];
                text += node.text.trim();
                print('Debug: Link node: href=$link, title=$linkTitle, text=${node.text.trim()}');
              } else if (node.localName == 'strong' || node.localName == 'sup') {
                node.nodes.forEach(parseNode);
              }
            }
          }

          pTag.nodes.forEach(parseNode);
        }

        final parsedItem = ParsedItem(
          text: text,
          isUnderlined: isUnderlined,
          isStrikethrough: isStrikethrough,
          fontSize: fontSize != null && fontSize!.isFinite ? fontSize! * scaleFactor : 16.0,
          color: color ?? defaultColor ?? Colors.black,
          fontName: fontName ?? defaultFontName,
          wordSpacing: wordSpacing != null && wordSpacing!.isFinite
              ? wordSpacing
              : wordSpacingItem != null && wordSpacingItem!.isFinite
              ? wordSpacingItem
              : 0.0,
          lineHeight: lineHeight != null && lineHeight!.isFinite
              ? lineHeight
              : lineHeightItem != null && lineHeightItem!.isFinite
              ? lineHeightItem
              : null,
          paragraphSpacing: paragraphSpacing != null && paragraphSpacing!.isFinite
              ? paragraphSpacing
              : paragraphSpacingItem != null && paragraphSpacingItem.isFinite
              ? paragraphSpacingItem
              : 8.0,
          link: link,
          linkTitle: linkTitle,
          textAlign: textAlign,
          isListItem: true,
          shadows: shadows,
        );

        // In giá trị của ParsedItem để debug
        parsedItem.debugPrint(items.length);
        items.add(parsedItem);
      }
    } else {
      // Xử lý thẻ <p> đơn lẻ
      final pTag = document.querySelector('p');
      if (pTag != null) {
        print('Debug: Tìm thấy thẻ <p> đơn lẻ');
        String text = '';
        bool isUnderlined = false;
        bool isStrikethrough = false;
        double? fontSize;
        Color? color;
        String? fontName;
        double? wordSpacingItem;
        double? lineHeightItem;
        double? paragraphSpacingItem;
        String? link;
        String? linkTitle;
        TextAlign textAlign = TextAlign.left;

        // Lấy style của <p>
        final pStyle = pTag.attributes['style']?.split(';') ?? [];
        print('Debug: Style của <p>: $pStyle');
        for (var style in pStyle) {
          if (style.contains('text-align')) {
            textAlign = style.contains('center') ? TextAlign.center : TextAlign.left;
            print('Debug: textAlign: $textAlign');
          }
          if (style.contains('font-size')) {
            fontSize = parseLength(style.split(':').last.trim());
            print('Debug: fontSize: $fontSize');
          }
          if (style.contains('color')) {
            color = parseColor(style.split(':').last.trim());
            print('Debug: color: $color');
          }
          if (style.contains('font-family')) {
            fontName = style.split(':').last.trim().replaceAll('"', '');
            print('Debug: fontName: $fontName');
          }
          if (style.contains('word-spacing')) {
            wordSpacingItem = parseLength(style.split(':').last.trim());
            print('Debug: wordSpacingItem: $wordSpacingItem');
          }
          if (style.contains('line-height')) {
            lineHeightItem = parseLineHeight(style.split(':').last.trim(), fontSize);
            print('Debug: lineHeightItem: $lineHeightItem');
          }
          if (style.contains('margin-bottom') || style.contains('padding-bottom')) {
            paragraphSpacingItem = parseLength(style.split(':').last.trim());
            print('Debug: paragraphSpacingItem: $paragraphSpacingItem');
          }
        }

        // Xử lý các thẻ con bên trong <p>
        void parseNode(dom.Node node) {
          if (node is dom.Text) {
            text += node.text.trim();
            print('Debug: Text node: ${node.text.trim()}');
          } else if (node is dom.Element) {
            if (node.localName == 'span') {
              final spanStyle = node.attributes['style']?.split(';') ?? [];
              print('Debug: Style của <span>: $spanStyle');
              for (var style in spanStyle) {
                if (style.contains('text-decoration')) {
                  isUnderlined = style.contains('underline');
                  isStrikethrough = style.contains('line-through');
                  print('Debug: isUnderlined: $isUnderlined, isStrikethrough: $isStrikethrough');
                }
                if (style.contains('font-size')) {
                  fontSize = parseLength(style.split(':').last.trim());
                  print('Debug: fontSize (span): $fontSize');
                }
                if (style.contains('font-family')) {
                  fontName = style.split(':').last.trim().replaceAll('"', '');
                  print('Debug: fontName (span): $fontName');
                }
                if (style.contains('word-spacing')) {
                  wordSpacingItem = parseLength(style.split(':').last.trim());
                  print('Debug: wordSpacingItem (span): $wordSpacingItem');
                }
                if (style.contains('line-height')) {
                  lineHeightItem = parseLineHeight(style.split(':').last.trim(), fontSize);
                  print('Debug: lineHeightItem (span): $lineHeightItem');
                }
              }
              node.nodes.forEach(parseNode);
            } else if (node.localName == 'a') {
              link = node.attributes['href'];
              linkTitle = node.attributes['title'];
              text += node.text.trim();
              print('Debug: Link node: href=$link, title=$linkTitle, text=${node.text.trim()}');
            } else if (node.localName == 'strong' || node.localName == 'sup') {
              node.nodes.forEach(parseNode);
            }
          }
        }

        pTag.nodes.forEach(parseNode);

        final parsedItem = ParsedItem(
          text: text,
          isUnderlined: isUnderlined,
          isStrikethrough: isStrikethrough,
          fontSize: fontSize != null && fontSize!.isFinite ? fontSize! * scaleFactor : 16.0,
          color: color ?? defaultColor ?? Colors.black,
          fontName: fontName ?? defaultFontName,
          wordSpacing: wordSpacing != null && wordSpacing!.isFinite
              ? wordSpacing
              : wordSpacingItem != null && wordSpacingItem!.isFinite
              ? wordSpacingItem
              : 0.0,
          lineHeight: lineHeight != null && lineHeight!.isFinite
              ? lineHeight
              : lineHeightItem != null && lineHeightItem!.isFinite
              ? lineHeightItem
              : null,
          paragraphSpacing: paragraphSpacing != null && paragraphSpacing!.isFinite
              ? paragraphSpacing
              : paragraphSpacingItem != null && paragraphSpacingItem.isFinite
              ? paragraphSpacingItem
              : 8.0,
          link: link,
          linkTitle: linkTitle,
          textAlign: textAlign,
          isListItem: false,
          shadows: shadows,
        );

        // In giá trị của ParsedItem để debug
        parsedItem.debugPrint(0);
        items.add(parsedItem);
      } else {
        print('Debug: Không tìm thấy thẻ <ul> hoặc <p>');
      }
    }

    print('Debug: Kết thúc parse HTML. Số ParsedItem: ${items.length}');
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final parsedItems = _parseHtml();

    if (parsedItems.isEmpty) {
      print('Debug: Không có ParsedItem để render');
      return const Center(child: Text('No content to display'));
    }

    // Nếu là danh sách, hiển thị dưới dạng ListView
    if (parsedItems.first.isListItem) {
      return ListView.builder(
        itemCount: parsedItems.length,
        itemBuilder: (context, index) {
          final item = parsedItems[index];
          final baseStyle = TextStyle(
            fontSize: item.fontSize ?? 16.0,
            color: item.color ?? Colors.black,
            wordSpacing: item.wordSpacing ?? 0.0,
            height: item.lineHeight != null &&
                item.fontSize != null &&
                item.lineHeight!.isFinite &&
                item.fontSize!.isFinite &&
                item.fontSize! > 0
                ? item.lineHeight! / item.fontSize!
                : 1.2,
            decoration: TextDecoration.combine([
              if (item.isUnderlined) TextDecoration.underline,
              if (item.isStrikethrough) TextDecoration.lineThrough,
            ]),
            shadows: item.shadows,
          );
          final textStyle = getGoogleFontStyle(item.fontName, baseStyle);

          print('Debug: Render ListItem #$index: text=${item.text}, fontSize=${item.fontSize}, height=${textStyle.height}, shadows=${item.shadows}');

          return Padding(
            padding: EdgeInsets.only(bottom: item.paragraphSpacing ?? 8.0),
            child: ListTile(
              leading: const Icon(Icons.fiber_manual_record, size: 16),
              title: InkWell(
                onTap: item.link != null
                    ? () {
                  print('Debug: Nhấn vào link: ${item.link}');
                }
                    : null,
                child: Text(
                  item.text,
                  textAlign: item.textAlign,
                  style: textStyle,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          );
        },
      );
    } else {
      // Nếu là đoạn văn, hiển thị dưới dạng Text
      final item = parsedItems.first;
      final baseStyle = TextStyle(
        fontSize: item.fontSize ?? 16.0,
        color: item.color ?? Colors.black,
        wordSpacing: item.wordSpacing ?? 0.0,
        height: item.lineHeight != null &&
            item.fontSize != null &&
            item.lineHeight!.isFinite &&
            item.fontSize!.isFinite &&
            item.fontSize! > 0
            ? item.lineHeight! / item.fontSize!
            : 1.2,
        decoration: TextDecoration.combine([
          if (item.isUnderlined) TextDecoration.underline,
          if (item.isStrikethrough) TextDecoration.lineThrough,
        ]),
        shadows: item.shadows,
      );
      final textStyle = getGoogleFontStyle(item.fontName, baseStyle);

      print('Debug: Render Text: text=${item.text}, fontSize=${item.fontSize}, height=${textStyle.height}, shadows=${item.shadows}');

      return Padding(
        padding: EdgeInsets.all(item.paragraphSpacing ?? 8.0),
        child: InkWell(
          onTap: item.link != null
              ? () {
            print('Debug: Nhấn vào link: ${item.link}');
          }
              : null,
          child: Text(
            item.text,
            textAlign: item.textAlign,
            style: textStyle,
            overflow: TextOverflow.visible,
          ),
        ),
      );
    }
  }
}