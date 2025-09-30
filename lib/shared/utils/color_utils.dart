import 'package:flutter/material.dart';

/// Converts a hex color string (e.g. `#AABBCC`) into a [Color].
Color colorFromHex(String hex) {
  final normalized = hex.replaceFirst('#', '');
  if (normalized.length == 6) {
    return Color(int.parse('FF$normalized', radix: 16));
  }
  if (normalized.length == 8) {
    return Color(int.parse(normalized, radix: 16));
  }
  throw FormatException('Invalid hex color: $hex');
}
