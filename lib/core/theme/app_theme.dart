import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Color Palette (Converted from your Hex Codes)
  static const Color primaryBackground = Color(0xFFFFF5DB);
  static const Color hoverColor = Color(0xFF00DF82);
  static const Color accentColor = Color(0xFF2CC295);
  static const Color secondaryColor1 = Color(0xFF03624C);
  static const Color secondaryColor2 = Color(0xFF042222);
  static const Color textColor = Color(0xFF021A1A);

  // 2. Spacing Constants (8pt Grid System)
  // Use these instead of random numbers to keep your layouts mathematically perfect
  static const double space8 = 8.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // 3. Global Theme Definition
  static ThemeData get lightTheme {
    // Base TextTheme using Inter for the body
    // Use a try-catch to gracefully handle font loading failures (e.g., no internet)
    TextTheme baseTextTheme;
    try {
      baseTextTheme = GoogleFonts.interTextTheme();
    } catch (_) {
      baseTextTheme = const TextTheme();
    }

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: primaryBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        primary: accentColor,
        secondary: secondaryColor1,
        surface: primaryBackground,
      ),

      // Typography: Roboto Slab (Headings) + Inter (Body)
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.robotoSlab(color: textColor, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.robotoSlab(color: textColor, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.robotoSlab(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.robotoSlab(color: textColor, fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.robotoSlab(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textColor, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textColor, fontSize: 14),
        labelLarge: GoogleFonts.inter(color: textColor, fontSize: 16, fontWeight: FontWeight.w600), // Button text
      ),

      // Iconography Defaults
      iconTheme: const IconThemeData(color: secondaryColor1, size: 24),

      // Component Styling: Cards (16px radius + Soft Shadow)
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4, // Subtle lift
        shadowColor: Colors.black.withValues(alpha: 0.05), // Maintains the clean, harsh-free look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Moderately Rounded
        ),
        margin: const EdgeInsets.symmetric(vertical: space8),
      ),

      // Component Styling: Inputs & Checkboxes (8px radius)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: space16, vertical: space16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Slightly Rounded inner elements
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: secondaryColor1),
        hintStyle: GoogleFonts.inter(color: secondaryColor1.withValues(alpha: 0.5)),
      ),
    );
  }
}
