import 'package:flutter/material.dart';

/// Paleta de colores de la marca BugTatsu Sec.
class AppColors {
  static const background = Color(0xFF0B1220);
  static const surface = Color(0xFF121B2E);
  static const border = Color(0xFF24324D);
  static const primary = Color(0xFF22D3EE);
  static const secondary = Color(0xFF8B5CF6);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFF43F5E);
  static const textMuted = Color(0xFF94A3B8);
}

/// Tema único de toda la aplicación (modo oscuro tipo terminal).
class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Color(0xFF04222A),
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
