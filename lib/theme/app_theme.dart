import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Paleta de cores
  static const Color primaryColor = Color(0xFF6A1B9A); // Roxo
  static const Color secondaryColor = Color(0xFFF48FB1); // Rosa (suave)
  static const Color accentColor = Color(0xFFFFD54F); // Dourado (destaque)
  static const Color lightBackground = Color(0xFFFFF8E1); // Bege claro (fundo)
  static const Color darkBackground = Color(0xFF121212); // Fundo escuro (não utilizado atualmente)
  static const Color textDark = Color(0xFF333333); // Texto principal
  static const Color textMuted = Color(0xFF666666); // Texto secundário
  static const Color textLight = Color(0xFFFFFFFF); // Texto claro
  static const Color success = Color(0xFF2E7D32); // Verde sucesso
  static const Color warning = Color(0xFFFFB300); // Amarelo aviso
  static const Color error = Color(0xFFD32F2F); // Vermelho erro
  static const Color divider = Color(0x1F000000); // Divisores sutis
  static const Color neutralGrey = Color(0xFF9E9E9E); // Ícones/textos desabilitados

  // 🌞 Tema Claro
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    iconTheme: const IconThemeData(color: textDark),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textDark, fontSize: 16),
      bodyMedium: TextStyle(color: textDark, fontSize: 14),
      bodySmall: TextStyle(color: textMuted, fontSize: 12),
      titleMedium: TextStyle(color: textDark, fontWeight: FontWeight.w600),
    ),
    dividerColor: divider,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: lightBackground,
      onPrimary: Colors.white,
      onSurface: textDark,
      error: error,
      onError: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightBackground,
      selectedItemColor: primaryColor,
      unselectedItemColor: neutralGrey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black87,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: accentColor,
      secondarySelectedColor: accentColor,
      labelStyle: TextStyle(color: textDark),
      secondaryLabelStyle: TextStyle(color: textDark),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: StadiumBorder(),
    ),
  );

  // 🌙 Tema Escuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textLight, fontSize: 16),
      bodyMedium: TextStyle(color: textLight, fontSize: 14),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: darkBackground,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
  );
}
