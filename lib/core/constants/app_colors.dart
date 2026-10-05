import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette — Deep Indigo-Blue
  static const Color primary = Color(0xFF3F51B5);
  static const Color primaryDark = Color(0xFF303F9F);
  static const Color primaryLight = Color(0xFF7986CB);
  static const Color primaryContainer = Color(0xFFE8EAF6);

  // Secondary palette — Teal
  static const Color secondary = Color(0xFF009688);
  static const Color secondaryDark = Color(0xFF00796B);
  static const Color secondaryLight = Color(0xFF4DB6AC);
  static const Color secondaryContainer = Color(0xFFE0F2F1);

  // Accent
  static const Color accent = Color(0xFFFF6F00);
  static const Color accentLight = Color(0xFFFFCC02);

  // Semantic
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFB8C00);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1E88E5);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Neutrals
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEEEEEE);

  // Text
  static const Color textPrimary = Color(0xFF1A1D2E);
  static const Color textSecondary = Color(0xFF6B7080);
  static const Color textTertiary = Color(0xFFB0B7C3);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textLink = Color(0xFF3F51B5);

  // Level badge colors
  static const Color beginner = Color(0xFF43A047);
  static const Color intermediate = Color(0xFFFB8C00);
  static const Color advanced = Color(0xFFE53935);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF3F51B5),
    Color(0xFF7C4DFF),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF009688),
    Color(0xFF4DB6AC),
  ];
  static const List<Color> heroGradient = [
    Color(0xFF1A1D2E),
    Color(0xFF3F51B5),
  ];
}
