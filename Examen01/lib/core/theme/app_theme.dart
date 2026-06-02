// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color background   = Color(0xFF141414);
  static const Color surface      = Color(0xFF1F1F1F);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color primary      = Color(0xFFE50914);
  static const Color primaryDark  = Color(0xFFB20710);
  static const Color white        = Color(0xFFFFFFFF);
  static const Color grey         = Color(0xFF9E9E9E);
  static const Color greyDark     = Color(0xFF424242);
  static const Color star         = Color(0xFFFFD700);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      onSurface: AppColors.white,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600);
        }
        return const TextStyle(color: AppColors.grey, fontSize: 12);
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedColor: AppColors.primary,
      labelStyle: const TextStyle(color: AppColors.white, fontSize: 12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(color: AppColors.grey, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.grey, fontSize: 12),
    ),
  );
}
