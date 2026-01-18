import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF2563EB); // Blue 600
  static const Color primaryLight = Color(0xFF3B82F6); // Blue 500
  static const Color primaryDark = Color(0xFF1D4ED8); // Blue 700

  // Secondary colors
  static const Color secondary = Color(0xFF64748B); // Slate 500
  static const Color secondaryLight = Color(0xFF94A3B8); // Slate 400
  static const Color secondaryDark = Color(0xFF475569); // Slate 600

  // Success colors
  static const Color success = Color(0xFF22C55E); // Green 500
  static const Color successLight = Color(0xFF4ADE80); // Green 400
  static const Color successDark = Color(0xFF16A34A); // Green 600

  // Warning colors
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFBBF24); // Amber 400
  static const Color warningDark = Color(0xFFD97706); // Amber 600

  // Error colors
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFF87171); // Red 400
  static const Color errorDark = Color(0xFFDC2626); // Red 600

  // Neutral colors - Light mode
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textTertiaryLight = Color(0xFF94A3B8); // Slate 400

  // Neutral colors - Dark mode
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color cardDark = Color(0xFF334155); // Slate 700
  static const Color dividerDark = Color(0xFF475569); // Slate 600
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiaryDark = Color(0xFF64748B); // Slate 500

  // Muscle group colors (for charts/visuals)
  static const Color chest = Color(0xFFEF4444);
  static const Color back = Color(0xFF3B82F6);
  static const Color shoulders = Color(0xFFF59E0B);
  static const Color arms = Color(0xFF8B5CF6);
  static const Color legs = Color(0xFF22C55E);
  static const Color core = Color(0xFFEC4899);
}
