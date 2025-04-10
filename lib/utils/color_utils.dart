import 'package:flutter/material.dart';

Color parseColor(String color) {
  if (color.startsWith('#')) {
    String hex = color.replaceAll('#', '');
    if (hex.length == 3) hex = hex.split('').map((c) => c + c).join(); // Mở rộng #333 thành #333333
    return Color(int.parse('ff$hex', radix: 16));
  } else if (color.startsWith('rgba')) {
    // Xử lý phân tích rgba(212,23,23,1)
    final parts = color.replaceAll(RegExp(r'[rgba()]'), '').split(',');
    return Color.fromRGBO(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
      double.parse(parts[3]),
    );
  }
  return Colors.black; // Giá trị dự phòng
}