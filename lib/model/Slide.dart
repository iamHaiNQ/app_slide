class Slide {
  final String id;
  final List<SlideElement> elements;
  final Background background;

  Slide({
    required this.id,
    required this.elements,
    required this.background,
  });

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      id: json['id'] as String? ?? '',
      elements: (json['elements'] as List<dynamic>?)
          ?.map((e) => SlideElement.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      background: Background.fromJson(
          json['background'] as Map<String, dynamic>? ?? {'type': 'solid', 'color': '#fff'}),
    );
  }
}

class SlideElement {
  final String type;
  final String id;
  final double width;
  final double? height;
  final double left;
  final double top;
  final String? src;
  final bool? flipV;
  final bool? flipH;
  final bool? fixedRadio;
  final String? colorMask;
  final Map<String, String>? filters;
  final Map<String, dynamic>? outline;
  final Map<String, dynamic>? shadow;
  final Map<String, dynamic>? clip;
  final String? path;
  final String? fill;
  final double? opacity;
  final double rotate;
  final String? content;
  final double? lineHeight;
  final String? defaultColor;
  final String? defaultFontName;
  final double? wordSpace;
  final double? paragraphSpace;
  final List<int>? viewBox;
  final bool? loop;
  final bool? autoplay;
  final bool? isYouTubeLink;
  final List<double>? start;
  final List<double>? end;
  final String? color;
  final String? style;
  final Map<String, dynamic>? additionalData;

  SlideElement({
    required this.type,
    required this.id,
    required this.width,
    this.height,
    required this.left,
    required this.top,
    this.src,
    this.flipV,
    this.flipH,
    this.fixedRadio,
    this.colorMask,
    this.filters,
    this.outline,
    this.shadow,
    this.clip,
    this.path,
    this.fill,
    this.opacity,
    required this.rotate,
    this.content,
    this.lineHeight,
    this.defaultColor,
    this.defaultFontName,
    this.wordSpace,
    this.paragraphSpace,
    this.viewBox,
    this.loop,
    this.autoplay,
    this.isYouTubeLink,
    this.start,
    this.end,
    this.color,
    this.style,
    this.additionalData,
  });

  factory SlideElement.fromJson(Map<String, dynamic> json) {
    return SlideElement(
      type: json['type'] as String? ?? 'text',
      id: json['id'] as String? ?? '',
      left: _toDouble(json['left'], 0.0), // Giá trị mặc định khi null
      top: _toDouble(json['top'], 0.0),
      width: _toDouble(json['width'], 0.0),
      height: _toDouble(json['height'], 0.0),
      src: json['src'] as String?,
      flipV: json['flipV'] as bool?,
      flipH: json['flipH'] as bool?,
      fixedRadio: json['fixedRadio'] as bool?,
      colorMask: json['colorMask'] as String?,
      filters: (json['filters'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
      ),
      outline: _parseOutline(json['outline']),
      shadow: _parseShadow(json['shadow']),
      clip: json['clip'] as Map<String, dynamic>?,
      path: json['path'] as String?,
      fill: json['fill'] as String?,
      opacity: _toDouble(json['opacity']),
      rotate: _toDouble(json['rotate'], 0.0),
      content: json['content'] as String?,
      lineHeight: _toDouble(json['lineHeight'], 0.0),
      defaultColor: json['defaultColor'] as String?,
      defaultFontName: json['defaultFontName'] as String?,
      wordSpace: _toDouble(json['wordSpace']),
      paragraphSpace: _toDouble(json['paragraphSpace'], 0.0),
      viewBox: (json['viewBox'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      loop: json['loop'] as bool?,
      autoplay: json['autoplay'] as bool?,
      isYouTubeLink: json['isYouTubeLink'] as bool?,
      start: (json['start'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      end: (json['end'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      color: json['color'] as String?,
      style: json['style'] as String?,
      additionalData: json
        ..removeWhere((k, v) => [
          'type',
          'id',
          'left',
          'top',
          'width',
          'height',
          'rotate',
          'src',
          'flipV',
          'flipH',
          'fixedRadio',
          'colorMask',
          'filters',
          'outline',
          'lineHeight',
          'shadow',
          'clip',
          'path',
          'fill',
          'opacity',
          'defaultColor',
          'defaultFontName',
          'wordSpace',
          'paragraphSpace',
          'viewBox',
          'loop',
          'autoplay',
          'isYouTubeLink',
          'content',
          'color',
          'style',
          'start',
          'end',
        ].contains(k)),
    );
  }

  static double _toDouble(dynamic value, [double defaultValue = double.nan]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static Map<String, dynamic>? _parseOutline(dynamic outline) {
    if (outline == null || outline is! Map<String, dynamic>) return null;
    return {
      'color': outline['color'] as String? ?? '#000000',
      'width': _toDouble(outline['width'], 0.0),
    };
  }

  static Map<String, dynamic>? _parseShadow(dynamic shadow) {
    if (shadow == null || shadow is! Map<String, dynamic>) return null;
    return {
      'color': shadow['color'] as String? ?? '#000000',
      'blur': _toDouble(shadow['blur'], 0.0),
      'h': _toDouble(shadow['h'], 0.0),
      'v': _toDouble(shadow['v'], 0.0),
    };
  }
}

class Background {
  final String type;
  final String color;

  Background({
    required this.type,
    required this.color,
  });

  factory Background.fromJson(Map<String, dynamic>? json) {
    return Background(
      type: json?['type'] as String? ?? 'solid',
      color: json?['color'] as String? ?? '#fff',
    );
  }
}