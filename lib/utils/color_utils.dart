import 'package:flutter/material.dart';

Color parseColor(String color) {
  color = color.trim();

  if (color.startsWith('#')) {
    String hex = color.substring(1);
    if (hex.length == 3) {
      // Chuyển #abc => #aabbcc
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 6) {
      hex = 'ff$hex'; // Thêm alpha mặc định (fully opaque)
    }
    return Color(int.parse(hex, radix: 16));
  } else if (color.startsWith('rgba')) {
    // rgba(212,23,23,1)
    final parts = RegExp(r'rgba?\(([^)]+)\)')
        .firstMatch(color)
        ?.group(1)
        ?.split(',')
        .map((s) => s.trim())
        .toList();

    if (parts != null && parts.length == 4) {
      return Color.fromRGBO(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
        double.parse(parts[3]),
      );
    }
  } else if (color.startsWith('rgb')) {
    // rgb(88, 108, 133)
    final parts = RegExp(r'rgb\(([^)]+)\)')
        .firstMatch(color)
        ?.group(1)
        ?.split(',')
        .map((s) => s.trim())
        .toList();

    if (parts != null && parts.length == 3) {
      return Color.fromRGBO(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
        1.0,
      );
    }
  }

  return Colors.black; // Fallback
}
