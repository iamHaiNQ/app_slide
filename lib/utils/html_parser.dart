import 'package:html/dom.dart';
import 'package:html/parser.dart';

class HtmlParser {
  final String listType;
  final String listFontSize;
  final String textAlign; // Thuộc tính textAlign được thêm vào
  final List<ListItem> items;

  HtmlParser({
    this.listType = '',
    this.listFontSize = '',
    this.textAlign = '', // Giá trị mặc định là chuỗi rỗng
    this.items = const [],
  });

  factory HtmlParser.fromHtml(String html) {
    final document = parse(html);
    final ul = document.querySelector('ul');
    if (ul == null) {
      return HtmlParser();
    }

    String listType = '';
    String listFontSize = '';
    String textAlign = ''; // Khởi tạo textAlign
    final style = ul.attributes['style'];
    if (style != null) {
      final styles = style.split(';').map((s) => s.trim()).toList();
      for (var s in styles) {
        if (s.startsWith('list-style-type:')) {
          listType = s.replaceFirst('list-style-type:', '').trim();
        } else if (s.startsWith('font-size:')) {
          listFontSize = s.replaceFirst('font-size:', '').trim();
        } else if (s.startsWith('text-align:')) {
          textAlign = s.replaceFirst('text-align:', '').trim(); // Lấy từ style
        }
      }
    }

    // Nếu không có style text-align, lấy từ thuộc tính align
    textAlign = ul.attributes['align'] ?? textAlign;

    final items = ul.children
        .where((e) => e.localName == 'li')
        .map((li) => ListItem.fromElement(li, parentAlign: textAlign)) // Truyền textAlign
        .toList();

    return HtmlParser(
      listType: listType,
      listFontSize: listFontSize,
      textAlign: textAlign, // Gán giá trị textAlign
      items: items,
    );
  }
}

class ListItem {
  final List<TextElement> texts;

  ListItem({this.texts = const []});

  factory ListItem.fromElement(Element element, {String parentAlign = ''}) {
    final texts = <TextElement>[];

    if (element.children.isEmpty) {
      final textElement = TextElement();
      textElement.parseElement(element);
      textElement.textAlign = textElement.textAlign.isNotEmpty
          ? textElement.textAlign
          : parentAlign; // Fallback từ parentAlign
      texts.add(textElement);
    } else {
      for (var child in element.nodes) {
        final textElement = TextElement();
        textElement.parseNode(child, parentAlign: parentAlign); // Truyền parentAlign
        if (textElement.text.trim().isNotEmpty) {
          texts.add(textElement);
        }
      }
    }

    return ListItem(texts: texts);
  }
}

class TextElement {
  String text = '';
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  bool isStrikethrough = false;
  bool isSubscript = false;
  bool isSuperscript = false;
  String textAlign = '';
  String fontFamily = '';
  String fontSize = '';
  String? color;

  void parseElement(Element element) {
    parseNode(element);
    text = text.trim();
  }

  void parseNode(
      Node node, {
        bool bold = false,
        bool italic = false,
        bool underline = false,
        bool strike = false,
        bool subscript = false,
        bool superscript = false,
        String parentAlign = '',
        String parentFontSize = '',
        String parentFontFamily = '',
        String? parentColor,
      }) {
    if (node is Text) {
      text += node.text;
      isBold |= bold;
      isItalic |= italic;
      isUnderline |= underline;
      isStrikethrough |= strike;
      isSubscript |= subscript;
      isSuperscript |= superscript;

      // Fallback attributes
      fontSize = fontSize.isNotEmpty ? fontSize : parentFontSize;
      fontFamily = fontFamily.isNotEmpty ? fontFamily : parentFontFamily;
      textAlign = textAlign.isNotEmpty ? textAlign : parentAlign; // Fallback textAlign
      color ??= parentColor;
    } else if (node is Element) {
      var newBold = bold;
      var newItalic = italic;
      var newUnderline = underline;
      var newStrike = strike;
      var newSub = subscript;
      var newSuper = superscript;
      var newAlign = parentAlign;
      var newFontSize = parentFontSize;
      var newFontFamily = parentFontFamily;
      String? newColor = parentColor;

      switch (node.localName?.toLowerCase()) {
        case 'b':
        case 'strong':
          newBold = true;
          break;
        case 'i':
        case 'em':
          newItalic = true;
          break;
        case 'u':
          newUnderline = true;
          break;
        case 's':
        case 'strike':
          newStrike = true;
          break;
        case 'sub':
          newSub = true;
          break;
        case 'sup':
          newSuper = true;
          break;
        case 'p':
        case 'div': // Hỗ trợ thêm div
          newAlign = node.attributes['align'] ?? parentAlign;
          break;
        case 'span':
          final style = node.attributes['style'];
          if (style != null) {
            for (var s in style.split(';')) {
              final kv = s.trim().split(':');
              if (kv.length != 2) continue;
              final key = kv[0].trim().toLowerCase();
              final value = kv[1].trim();

              switch (key) {
                case 'font-size':
                  newFontSize = value;
                  break;
                case 'font-family':
                  newFontFamily = value;
                  break;
                case 'text-decoration':
                  final decorations = value.split(' ');
                  if (decorations.contains('underline')) newUnderline = true;
                  if (decorations.contains('line-through')) newStrike = true;
                  break;
                case 'color':
                  newColor = value;
                  break;
                case 'text-align':
                  newAlign = value;
                  break;
              }
            }
          }
          break;
      }

      for (var child in node.nodes) {
        parseNode(
          child,
          bold: newBold,
          italic: newItalic,
          underline: newUnderline,
          strike: newStrike,
          subscript: newSub,
          superscript: newSuper,
          parentAlign: newAlign,
          parentFontSize: newFontSize,
          parentFontFamily: newFontFamily,
          parentColor: newColor,
        );
      }
    }
  }

  /// Trả về mã màu đã xử lý, nếu không có thì fallback mặc định
  String getResolvedColor([String fallback = '#000000']) {
    return (color != null && color!.isNotEmpty) ? color! : fallback;
  }
}