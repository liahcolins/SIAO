import 'package:flutter/material.dart';

abstract class AppColors {
  // Cores Institucionais Féis ao Protótipo UFMA (Teal Verde)
  static const Color primaryTeal = Color(0xFF00796B);       // Teal Principal
  static const Color primaryDarkTeal = Color(0xFF005248);   // Header / AppBar
  static const Color primaryLightTeal = Color(0xFFE0F2F1);  // Destaques e cards claros
  static const Color tealButtonBg = Color(0xFF00796B);      // Botões arredondados no estilo pílula

  // Cores Complementares Elegantes
  static const Color accentOrange = Color(0xFFE65100);
  static const Color warningBg = Color(0xFFFFF8E1);
  static const Color warningBorder = Color(0xFFFFE082);
  static const Color warningText = Color(0xFFB78103);

  // Status
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color dangerRed = Color(0xFFC62828);

  // Backgrounds & Surfaces
  static const Color bgLight = Color(0xFFF4F7F6);
  static const Color cardSurfaceLight = Color(0xFFFFFFFF);

  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardSurfaceDark = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}
