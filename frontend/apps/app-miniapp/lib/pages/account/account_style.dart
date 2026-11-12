import 'package:flutter/material.dart';

abstract final class AccountStyle {
  static const double pageInset = 16;
  static const double cardRadius = 16;
  static const double controlRadius = 14;

  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(
    pageInset,
    10,
    pageInset,
    30,
  );

  static const Duration animation = Duration(milliseconds: 180);

  static Color pageBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF17191C)
        : const Color(0xFFF4F5F6);
  }

  static Color cardBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerLowest;
  }

  static Color mutedText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}
