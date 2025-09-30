import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provides themed configurations for the PokiFairy application.
class AppTheme {
  /// Prevents direct instantiation.
  const AppTheme._();

  static const Color _primarySeed = Color(0xFFBDE0FE);
  static const Color _secondarySeed = Color(0xFFFACBEA);
  static const Color _tertiarySeed = Color(0xFFE5FFD5);

  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = ThemeData(brightness: brightness).textTheme;
    final noto = GoogleFonts.notoSansKrTextTheme(base);
    return noto.copyWith(
      headlineLarge: noto.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: noto.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: noto.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: noto.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      bodyLarge: noto.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: noto.bodyMedium?.copyWith(height: 1.45),
      labelLarge: noto.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  static ChipThemeData _chipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      selectedColor: colorScheme.primaryContainer,
      secondarySelectedColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
      secondaryLabelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  /// Creates the light theme with pastel-friendly surfaces and rounded elements.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      primary: _primarySeed,
      secondary: _secondarySeed,
      tertiary: _tertiarySeed,
      brightness: Brightness.light,
    );
    final textTheme = _buildTextTheme(Brightness.light);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFFFDF9FF),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.primaryContainer.withValues(alpha: 0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primaryContainer.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: _chipTheme(colorScheme),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.primaryContainer,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Creates the dark theme while preserving the pastel accent palette.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      primary: _primarySeed,
      secondary: _secondarySeed,
      tertiary: _tertiarySeed,
      brightness: Brightness.dark,
    );
    final textTheme = _buildTextTheme(Brightness.dark).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFF1D1A29),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: const Color(0xFF272338),
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: _chipTheme(colorScheme).copyWith(
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.9),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
