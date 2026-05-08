import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Eco-Friendly Color Palette
  static const Color primaryGreen = Color(0xFF00A870);
  static const Color lightGreen = Color(0xFF7CE7BA);
  static const Color darkGreen = Color(0xFF006B55);
  static const Color accentBlue = Color(0xFF0EA5E9);
  static const Color lightBlue = Color(0xFF8EDBFF);
  static const Color darkBlue = Color(0xFF075985);
  static const Color ink = Color(0xFF071826);
  static const Color mist = Color(0xFFF4FBF8);
  static const Color aquaMist = Color(0xFFEAF8FF);
  static const Color premiumLine = Color(0xFFE0F1EC);

  // Glassmorphism Colors
  static const Color glassWhite = Color(0xFFFFFFFF);
  static const Color glassBlack = Color(0xFF000000);
  static const Color glassGrey = Color(0xFF9E9E9E);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF7FBF8);
  static const Color backgroundDark = Color(0xFF071826);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF071826);
  static const Color textSecondary = Color(0xFF58706B);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentBlue,
        surface: surfaceLight,
        background: backgroundLight,
        error: error,
        onPrimary: textLight,
        onSecondary: textLight,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: textLight,
      ),

      // Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 29,
          fontWeight: FontWeight.w900,
          color: textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 25,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 8,
        shadowColor: ink.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textLight,
          elevation: 0,
          shadowColor: primaryGreen.withOpacity(0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: textLight,
        elevation: 12,
        shape: CircleBorder(),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.92),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: premiumLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: accentBlue,
        surface: surfaceDark,
        background: backgroundDark,
        error: error,
        onPrimary: textLight,
        onSecondary: textLight,
        onSurface: textLight,
        onBackground: textLight,
        onError: textLight,
      ),

      // Typography
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textLight,
            ),
            displayMedium: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textLight,
            ),
            headlineLarge: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textLight,
            ),
            headlineMedium: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textLight,
            ),
            bodyLarge: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: textLight,
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: textLight.withOpacity(0.7),
            ),
            labelLarge: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textLight,
            ),
          ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        iconTheme: const IconThemeData(color: textLight),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textLight,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: textLight,
        elevation: 12,
        shape: CircleBorder(),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: glassGrey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: textLight.withOpacity(0.7),
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: textLight.withOpacity(0.5),
          fontSize: 14,
        ),
      ),
    );
  }

  // Glassmorphism Decoration
  static BoxDecoration glassDecoration({
    Color? color,
    double borderRadius = 20,
    double blur = 10,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white.withOpacity(0.82),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? premiumLine,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: ink.withOpacity(0.08),
          blurRadius: blur + 8,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Gradient Decoration
  static BoxDecoration gradientDecoration({
    List<Color>? colors,
    double borderRadius = 20,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors ?? [primaryGreen, accentBlue],
        begin: begin ?? Alignment.topLeft,
        end: end ?? Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static const LinearGradient premiumBackground = LinearGradient(
    colors: [mist, aquaMist, Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumDarkBackground = LinearGradient(
    colors: [Color(0xFF071826), Color(0xFF063443), Color(0xFF08251F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
