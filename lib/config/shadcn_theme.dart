import 'package:flutter/material.dart';

/// Shadcn-inspired design system colors
class ShadcnColors {
  // Complete Zinc Palette
  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);

  // Semantic colors
  static const Color background = Colors.white;
  static const Color foreground = zinc950;

  static const Color card = Colors.white;
  static const Color cardForeground = zinc950;

  static const Color popover = Colors.white;
  static const Color popoverForeground = zinc950;

  static const Color primary = zinc900;
  static const Color primaryForeground = zinc50;

  static const Color secondary = zinc100;
  static const Color secondaryForeground = zinc900;

  static const Color muted = zinc100;
  static const Color mutedForeground = zinc500;

  static const Color accent = zinc100;
  static const Color accentForeground = zinc900;

  static const Color destructive = Color(0xFFEF4444); // Red 500
  static const Color destructiveForeground = zinc50;

  static const Color border = zinc200;
  static const Color input = zinc200;
  static const Color ring = zinc900;
}

/// Spacing system based on 4px grid
class ShadcnSpacing {
  static const double xxs = 2.0; // 0.125rem
  static const double xs = 4.0; // 0.25rem
  static const double sm = 8.0; // 0.5rem
  static const double md = 12.0; // 0.75rem
  static const double lg = 16.0; // 1rem
  static const double xl = 20.0; // 1.25rem
  static const double xl2 = 24.0; // 1.5rem
  static const double xl3 = 32.0; // 2rem
  static const double xl4 = 40.0; // 2.5rem
  static const double xl5 = 48.0; // 3rem
}

/// Border radius system
class ShadcnRadius {
  static const double sm = 4.0; // 0.25rem
  static const double md = 8.0; // 0.5rem
  static const double lg = 12.0; // 0.75rem
  static const double xl = 16.0; // 1rem
  static const double xl2 = 20.0; // 1.25rem
  static const double full = 9999.0; // For pills
}

/// Shadow system
class ShadcnShadows {
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

class ShadcnThemeData {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ShadcnColors.background,
      colorScheme: const ColorScheme.light(
        primary: ShadcnColors.primary,
        onPrimary: ShadcnColors.primaryForeground,
        secondary: ShadcnColors.secondary,
        onSecondary: ShadcnColors.secondaryForeground,
        surface: ShadcnColors.card,
        onSurface: ShadcnColors.cardForeground,
        error: ShadcnColors.destructive,
        onError: ShadcnColors.destructiveForeground,
        outline: ShadcnColors.border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ShadcnColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: ShadcnColors.foreground),
        titleSpacing: ShadcnSpacing.lg,
        titleTextStyle: const TextStyle(
          color: ShadcnColors.foreground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ShadcnColors.border,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: ShadcnColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadcnRadius.lg),
          side: const BorderSide(color: ShadcnColors.border, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        // H1 - Display Large
        displayLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: ShadcnColors.foreground,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        // H2 - Display Medium
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.foreground,
          letterSpacing: -0.6,
          height: 1.3,
        ),
        // H3 - Display Small
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.foreground,
          letterSpacing: -0.4,
          height: 1.4,
        ),
        // Title - Headline Medium
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.foreground,
          letterSpacing: -0.2,
        ),
        // Body Large
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ShadcnColors.foreground,
          height: 1.5,
          letterSpacing: 0,
        ),
        // Body Medium
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ShadcnColors.foreground,
          height: 1.4,
          letterSpacing: 0,
        ),
        // Body Small / Muted
        bodySmall: TextStyle(
          fontSize: 13,
          color: ShadcnColors.mutedForeground,
          height: 1.4,
        ),
        // Label
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ShadcnColors.foreground,
          letterSpacing: 0,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ShadcnColors.mutedForeground,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
