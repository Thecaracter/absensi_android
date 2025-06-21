// File: lib/app/utils/color_constant.dart

import 'package:flutter/material.dart';

class AppColors {
  // Filament Slate Colors
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // Filament Amber Colors
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);

  // Filament Yellow Colors
  static const Color yellow50 = Color(0xFFFEFCE8);
  static const Color yellow100 = Color(0xFFFEF9C3);
  static const Color yellow200 = Color(0xFFFEF08A);
  static const Color yellow300 = Color(0xFFFDE047);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color yellow600 = Color(0xFFCA8A04);
  static const Color yellow700 = Color(0xFFA16207);
  static const Color yellow800 = Color(0xFF854D0E);
  static const Color yellow900 = Color(0xFF713F12);

  // Filament Red Colors (untuk error states)
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);
  static const Color red900 = Color(0xFF7F1D1D);

  // Filament Green Colors (untuk success states)
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);
  static const Color green900 = Color(0xFF14532D);

  // Common App Colors (Dark Theme - Original)
  static const Color primary = amber500;
  static const Color primaryDark = amber600;
  static const Color secondary = yellow500;
  static const Color background = slate900;
  static const Color backgroundLight = slate800;
  static const Color surface = slate800;
  static const Color surfaceLight = slate700;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = slate400;
  static const Color textMuted = slate500;
  static const Color border = slate600;
  static const Color borderFocus = amber500;
  static const Color error = red500;
  static const Color success = green500;
  static const Color warning = yellow500;

  // Light Theme Colors (Tambahan untuk Light Mode)
  static const Color primaryLight = amber600;
  static const Color backgroundLightMode = slate50;
  static const Color surfaceLightMode = Colors.white;
  static const Color textPrimaryLight = slate900;
  static const Color textSecondaryLight = slate600;
  static const Color textMutedLight = slate500;
  static const Color borderLight = slate300;
  static const Color borderFocusLight = amber600;

  // Gradient Definitions (Dark Theme)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber500, yellow500],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [slate900, slate800],
  );

  static const LinearGradient disabledGradient = LinearGradient(
    colors: [slate600, slate700],
  );

  // Light Theme Gradients (Tambahan)
  static const LinearGradient primaryGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber600, yellow600],
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [slate50, slate100],
  );

  static const LinearGradient disabledGradientLight = LinearGradient(
    colors: [slate300, slate400],
  );

  // Shadow Colors
  static Color primaryShadow = amber500.withOpacity(0.3);
  static Color cardShadow = Colors.black.withOpacity(0.1);
  static Color buttonShadow = amber500.withOpacity(0.4);

  // Light Theme Shadow Colors
  static Color cardShadowLight = slate300.withOpacity(0.3);
  static Color buttonShadowLight = amber600.withOpacity(0.3);
}
