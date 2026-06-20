import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF3B0764); // Deep Amethyst
  static const Color secondaryColor = Color(0xFF764AA0);
  static const Color backgroundColor = Color(0xFFFFF7FE);
  static const Color surfaceColor = Color(0xFFFFF7FE);
  static const Color surfaceContainerColor = Color(0xFFF4EBF4);
  static const Color surfaceContainerLow = Color(0xFFFAF1F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurfaceColor = Color(0xFF1E1A20);
  static const Color onSurfaceVariant = Color(0xFF4B4450);
  static const Color outlineColor = Color(0xFF7D7481);
  static const Color outlineVariantColor = Color(0xFFCEC3D1);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color successColor = Color(0xFF10B981);
  static const Color pendingColor = Color(0xFFF59E0B);

  // App Bar and Bottom Nav spacings
  static const double topBarHeight = 48.0;
  static const double bottomNavHeight = 64.0;

  // BorderRadius
  static const double radiusDefault = 4.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radius2Xl = 24.0;

  // Spacing
  static const double spacingBase = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;

  // Ambient Shadow
  static List<BoxShadow> ambientShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      offset: const Offset(0, 2),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  static List<BoxShadow> hoverShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: onSurfaceColor,
        onSurface: onSurfaceColor,
        surfaceVariant: surfaceContainerColor,
        onSurfaceVariant: onSurfaceVariant,
        outline: outlineColor,
        outlineVariant: outlineVariantColor,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.hankenGrotesk(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.02,
          color: onSurfaceColor,
        ),
        headlineLarge: GoogleFonts.hankenGrotesk(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        headlineMedium: GoogleFonts.hankenGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        headlineSmall: GoogleFonts.hankenGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        titleLarge: GoogleFonts.hankenGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: onSurfaceColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: onSurfaceColor,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: onSurfaceColor,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        labelMedium: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: onSurfaceVariant,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: outlineVariantColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: outlineVariantColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: errorColor),
        ),
      ),
    );
  }

  static String formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final dayStr = date.day.toString().padLeft(2, '0');
    return "${months[date.month - 1]} $dayStr, ${date.year}";
  }
}
