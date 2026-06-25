import 'package:flutter/material.dart';

class FluentTheme {
  // Fluent Colors
  static const Color accentColor = Color(0xFF0078D4); // Windows Accent Blue
  static const Color accentHoverColor = Color(0xFF106EBE);
  static const Color accentPressedColor = Color(0xFF005A9E);
  
  static const Color successColor = Color(0xFF107C41); // Excel green / battery good
  static const Color warningColor = Color(0xFFD83B01); // Windows Warning Red/Orange
  static const Color infoColor = Color(0xFF0078D4);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF202020); // Mica-like dark base
  static const Color darkSurface = Color(0xFF2C2C2C); // Acrylic cards
  static const Color darkSurfaceSecondary = Color(0xFF333333);
  static const Color darkBorder = Color(0xFF404040);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFADADAD);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF3F3F3); // Mica-like light base
  static const Color lightSurface = Color(0xFFFFFFFF); // Acrylic cards
  static const Color lightSurfaceSecondary = Color(0xFFE5E5E5);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF202020);
  static const Color lightTextSecondary = Color(0xFF5F5F5F);

  // Light ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: accentColor,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: accentColor,
        secondary: accentColor,
        surface: lightSurface,
        background: lightBackground,
        error: warningColor,
      ),
      fontFamily: 'Segoe UI',
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: lightBorder, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return lightTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return accentColor;
          return Colors.transparent;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return lightBorder;
        }),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w500, fontSize: 16),
        bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 13),
      ),
    );
  }

  // Dark ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: accentColor,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: accentColor,
        surface: darkSurface,
        background: darkBackground,
        error: warningColor,
      ),
      fontFamily: 'Segoe UI',
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: darkBorder, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return accentColor;
          return Colors.transparent;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return darkBorder;
        }),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w500, fontSize: 16),
        bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 13),
      ),
    );
  }

  // Acrylic card-like styling helper
  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? darkSurface : Colors.white.withOpacity(0.8),
      border: Border.all(
        color: isDark ? darkBorder : lightBorder,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Inner border effect (Fluent look)
  static BoxDecoration fluentCardDecoration(BuildContext context, {bool isSelected = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isSelected
          ? (isDark ? accentColor.withOpacity(0.1) : accentColor.withOpacity(0.08))
          : (isDark ? darkSurface : lightSurface),
      border: Border.all(
        color: isSelected
            ? accentColor
            : (isDark ? darkBorder : lightBorder),
        width: 1.2,
      ),
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: accentColor.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }
}
