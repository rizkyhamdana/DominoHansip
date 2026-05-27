import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette (Playful Board-Game Cartoon Style) ─────────────────────────────
  static const Color background = Color(0xFFFFFDF5); // Warm cream board background
  static const Color tableSurface = Color(0xFF23A89C); // Vibrant board-game teal
  static const Color cardSurface = Color(0xFFFFFFFF); // Chunky pure white cards
  static const Color cardBorder = Color(0xFF1E2229); // Thick dark charcoal outlines

  static const Color gold = Color(0xFFFFD166); // Bouncy warm yellow/gold
  static const Color goldLight = Color(0xFFFFE194);
  static const Color goldDark = Color(0xFFD4A316);

  static const Color teal = Color(0xFF06D6A0); // Bubbly mint teal
  static const Color tealLight = Color(0xFF4EE8C4);

  static const Color bigStoneMaroon = Color(0xFFFF6B6B); // Soft playful red/coral
  static const Color bigStoneGold = Color(0xFFFFD166);
  static const Color smallStoneIvory = Color(0xFFECE2D0); // Cozy warm pebble cream
  static const Color smallStoneDark = Color(0xFF8D8270);

  static const Color textPrimary = Color(0xFF232B38); // Soft dark slate text (no pure black)
  static const Color textSecondary = Color(0xFF5A667A); // Slate-gray secondary text
  static const Color textMuted = Color(0xFF8F9BB3); // Light gray-blue placeholder text

  static const Color success = Color(0xFF4CAF50); // Playful green
  static const Color error = Color(0xFFE53E3E); // Bold comic red
  static const Color warning = Color(0xFFFF9800); // Bouncy orange

  // Player avatar palette (super bright, colorful, comfortable)
  static const List<Color> avatarColors = [
    Color(0xFFFF8B94), // Pastel Coral Pink
    Color(0xFFFFD3B6), // Soft Peach
    Color(0xFFA8E6CF), // Soft Mint Green
    Color(0xFFDCEDC8), // Soft Lime Green
    Color(0xFFB39DDB), // Soft Violet Purple
    Color(0xFF90CAF9), // Soft Sky Blue
  ];

  // ── Spacing (Comfortable) ──────────────────────────────────────────────────
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;

  // ── Radius (Chunky, Playful, Bubbly) ───────────────────────────────────────
  static const double radiusSM = 8;
  static const double radiusMD = 16;   // Bubbly Medium
  static const double radiusLG = 24;   // Extra Chunky
  static const double radiusXL = 32;   // Bubbly Large
  static const double radiusRound = 100;

  // ── Theme (Adapted for colorful light look) ────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: gold,
        secondary: teal,
        surface: cardSurface,
        error: error,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.inter(
          color: textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          side: const BorderSide(color: cardBorder, width: 2), // Thick 2px border!
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: textPrimary,
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLG,
            vertical: spaceMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLG),
            side: const BorderSide(color: cardBorder, width: 2), // Thick 2px border!
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: cardBorder, width: 2), // Thick 2px border!
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLG,
            vertical: spaceMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLG),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: cardBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: cardBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: goldDark, width: 2.5),
        ),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMD,
          vertical: spaceMD,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardSurface,
        contentTextStyle: GoogleFonts.inter(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          side: const BorderSide(color: cardBorder, width: 2),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: cardBorder,
        thickness: 2,
        space: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXL),
          ),
          side: BorderSide(color: cardBorder, width: 2),
        ),
        dragHandleColor: cardBorder,
        showDragHandle: true,
      ),
    );
  }
}

// ── Decoration helpers ────────────────────────────────────────────────────────
extension AppDecorations on BoxDecoration {
  static BoxDecoration glassCard({
    Color color = AppTheme.cardSurface,
    double radius = AppTheme.radiusLG,
    bool showBorder = true,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(color: AppTheme.cardBorder, width: 2) // Thick 2px border!
          : null,
      boxShadow: [
        // Bold flat 2D shadow (hand-drawn sticker feel)
        BoxShadow(
          color: AppTheme.cardBorder.withOpacity(0.15),
          blurRadius: 0,
          offset: const Offset(4, 4),
        ),
      ],
    );
  }

  static BoxDecoration goldGlow() => glassCard(glowColor: AppTheme.gold);
  static BoxDecoration tealGlow() => glassCard(glowColor: AppTheme.teal);
}
