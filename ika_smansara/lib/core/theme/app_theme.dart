/// App Theme - IKA SMANSARA
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    // Base TextTheme with Inter
    final baseTextTheme = GoogleFonts.interTextTheme();

    // Override headings with Poppins
    final textTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.poppins(textStyle: baseTextTheme.displayLarge),
      displayMedium: GoogleFonts.poppins(
        textStyle: baseTextTheme.displayMedium,
      ),
      displaySmall: GoogleFonts.poppins(textStyle: baseTextTheme.displaySmall),
      headlineLarge: GoogleFonts.poppins(
        textStyle: baseTextTheme.headlineLarge,
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: baseTextTheme.headlineMedium,
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: baseTextTheme.headlineSmall,
      ),
      titleLarge: GoogleFonts.poppins(textStyle: baseTextTheme.titleLarge),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textLight, fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primaryLight,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Base TextTheme with Inter
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );

    // Override headings with Poppins
    final textTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.poppins(textStyle: baseTextTheme.displayLarge),
      displayMedium: GoogleFonts.poppins(
        textStyle: baseTextTheme.displayMedium,
      ),
      displaySmall: GoogleFonts.poppins(textStyle: baseTextTheme.displaySmall),
      headlineLarge: GoogleFonts.poppins(
        textStyle: baseTextTheme.headlineLarge,
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: baseTextTheme.headlineMedium,
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: baseTextTheme.headlineSmall,
      ),
      titleLarge: GoogleFonts.poppins(textStyle: baseTextTheme.titleLarge),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFF111827), // Grey 900
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Color(0xFF1F2937), // Grey 800
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFF9FAFB), // Grey 50
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Color(0xFFF9FAFB),
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1F2937),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF374151)), // Grey 700
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF374151), // Grey 700
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4B5563)), // Grey 600
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4B5563)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F2937),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF374151),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF374151),
        selectedColor: AppColors.primaryDark,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
