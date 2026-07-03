import 'package:flutter/material.dart';

class TextStyles {
  static TextStyle? myTextStyle(Color color, double size, bool isBold) {
    return TextStyle(
      fontSize: size,
      color: color,
      fontFamily: 'Cairo',
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
  }
}
