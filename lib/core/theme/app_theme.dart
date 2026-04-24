import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8E7CF8);
  static const Color primaryDark = Color(0xFF4A3AB5);
  static const Color secondaryColor = Color(0xFFFF6B9D);
  static const Color accentColor = Color(0xFF00CEC9);
  static const Color backgroundColor = Color(0xFFF8F9FE);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textDarkColor = Color(0xFF2D3436);
  static const Color textMediumColor = Color(0xFF636E72);
  static const Color textLightColor = Color(0xFFB2BEC3);
  static const Color errorColor = Color(0xFFE17055);
  static const Color successColor = Color(0xFF00B894);
  static const Color warningColor = Color(0xFFFDCB6E);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: textDarkColor, fontWeight: FontWeight.bold, fontSize: 28),
        displayMedium: GoogleFonts.poppins(
          color: textDarkColor, fontWeight: FontWeight.bold, fontSize: 24),
        headlineMedium: GoogleFonts.poppins(
          color: textDarkColor, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: GoogleFonts.poppins(
          color: textDarkColor, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: GoogleFonts.poppins(
          color: textDarkColor, fontWeight: FontWeight.w500, fontSize: 16),
        bodyLarge: GoogleFonts.poppins(color: textDarkColor, fontSize: 16),
        bodyMedium: GoogleFonts.poppins(color: textMediumColor, fontSize: 14),
        bodySmall: GoogleFonts.poppins(color: textLightColor, fontSize: 12),
        labelLarge: GoogleFonts.poppins(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textDarkColor),
        titleTextStyle: GoogleFonts.poppins(
          color: textDarkColor, fontSize: 20, fontWeight: FontWeight.w700),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.poppins(color: textLightColor, fontSize: 14),
        labelStyle: GoogleFonts.poppins(color: textMediumColor, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
        shadowColor: const Color(0x1A6C5CE7),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLightColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEF5),
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F0F8),
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}