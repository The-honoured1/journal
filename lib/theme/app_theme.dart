import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── MIDNIGHT INK PALETTE ───────────────────────────────────────────────
  //
  // DARK: Deep navy-indigo backgrounds, electric violet accent, warm amber
  // LIGHT: Rich parchment ivory, deep ink primary, golden-amber accent
  //

  // Light theme primaries
  static const lightPrimary = Color(0xFF3D2B8E);   // Deep ink violet
  static const lightAccent  = Color(0xFFE07B3C);   // Burnt amber
  static const lightBg      = Color(0xFFF5F0E8);   // Warm parchment
  static const lightSurface = Color(0xFFFCF9F4);   // Cream white
  static const lightCard    = Color(0xFFFFFDF8);   // Soft off-white card
  static const lightBorder  = Color(0xFFE8DFD0);   // Warm sand divider

  // Dark theme primaries
  static const darkPrimary  = Color(0xFF9B7FE8);   // Soft electric violet
  static const darkAccent   = Color(0xFFF0A057);   // Warm glowing amber
  static const darkBg       = Color(0xFF0E0C1A);   // True midnight navy-black
  static const darkSurface  = Color(0xFF16132A);   // Rich indigo-dark
  static const darkCard     = Color(0xFF1E1A35);   // Deep violet card
  static const darkBorder   = Color(0xFF2E2A4A);   // Subtle indigo border

  // Semantic colors (shared)
  static const errorColor   = Color(0xFFE05C5C);
  static const successColor = Color(0xFF5CB88A);

  static const cardRadius   = 24.0;
  static const buttonRadius = 18.0;

  // ─── LIGHT THEME ────────────────────────────────────────────────────────
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightAccent,
        surface: lightSurface,
        background: lightBg,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1A1628),
        onBackground: Color(0xFF1A1628),
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A1628),
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1628),
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1628),
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1628),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: const Color(0xFF3D3652),
          height: 1.65,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: const Color(0xFF6B6282),
          height: 1.5,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: lightPrimary,
          letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9E98B5),
          letterSpacing: 0.8,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0EBE0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightPrimary, width: 1.5),
        ),
        labelStyle: GoogleFonts.outfit(color: const Color(0xFF9E98B5), fontSize: 14),
        hintStyle: GoogleFonts.outfit(color: const Color(0xFF9E98B5), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return lightPrimary;
          return const Color(0xFFD0C8E8);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return lightPrimary.withOpacity(0.3);
          return const Color(0xFFE8E2F5);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1628),
        contentTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ─── DARK THEME ─────────────────────────────────────────────────────────
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkAccent,
        surface: darkSurface,
        background: darkBg,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF1A1628),
        onSurface: Color(0xFFEDE8FF),
        onBackground: Color(0xFFEDE8FF),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFEDE8FF),
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFEDE8FF),
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFEDE8FF),
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFEDE8FF),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: const Color(0xFFB8B0D8),
          height: 1.65,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: const Color(0xFF8880A8),
          height: 1.5,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: darkPrimary,
          letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6860A0),
          letterSpacing: 0.8,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF201C38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkPrimary, width: 1.5),
        ),
        labelStyle: GoogleFonts.outfit(color: const Color(0xFF6860A0), fontSize: 14),
        hintStyle: GoogleFonts.outfit(color: const Color(0xFF6860A0), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return darkPrimary;
          return const Color(0xFF4A4468);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return darkPrimary.withOpacity(0.35);
          return const Color(0xFF2E2A4A);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2A2545),
        contentTextStyle: GoogleFonts.outfit(color: const Color(0xFFEDE8FF), fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
