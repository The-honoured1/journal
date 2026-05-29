import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFFF6B73C); // Warm amber
  static const secondaryColor = Color(0xFF784136); // Cocoa brown
  static const greenAccent = Color(0xFF839B3D); // Calm green
  static const grayAccent = Color(0xFF706E66); // Anxious/slate gray

  static const lightBg = Color(0xFFF5F5F2); // Warm soft off-white
  static const lightSurface = Colors.white;

  static const darkBg = Color(0xFF141311); // Comfortable warm-black
  static const darkSurface = Color(0xFF22201D);

  static const cardRadius = 24.0;
  static const buttonRadius = 16.0;

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        background: lightBg,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C2A29),
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C2A29),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: const Color(0xFF5C5A58),
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: const Color(0xFF7C7975),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: darkSurface,
        background: darkBg,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFECE7E2),
            ),
            titleLarge: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFECE7E2),
            ),
            bodyLarge: GoogleFonts.outfit(
              fontSize: 16,
              color: const Color(0xFF9E9992),
              height: 1.5,
            ),
            bodyMedium: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFF7C7975),
            ),
          ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
    );
  }
}
