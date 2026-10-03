import 'package:flutter/material.dart';

class ColorUtils {
  static const Color defaultListColor = Color(0xFF6366F1); // Indigo

  static const List<Color> presetColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF3B82F6), // Blue
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFF97316), // Orange
    Color(0xFFF43F5E), // Rose
    Color(0xFFA855F7), // Purple
    Color(0xFF64748B), // Slate
  ];

  static Color fromHex(
    String? hexString, {
    Color defaultColor = defaultListColor,
  }) {
    if (hexString == null || hexString.trim().isEmpty) {
      return defaultColor;
    }
    String hex = hexString.replaceAll('#', '').trim();
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    final intColor = int.tryParse(hex, radix: 16);
    if (intColor == null) {
      return defaultColor;
    }
    return Color(intColor);
  }

  static String toHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
