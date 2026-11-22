import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF231B16);
  static const bark = Color(0xFF4B3327);
  static const ember = Color(0xFFCB5B31);
  static const cream = Color(0xFFFFF8EE);
  static const paper = Color(0xFFF4EBDD);
  static const muted = Color(0xFF81756A);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ember,
          primary: ember,
          secondary: bark,
          surface: cream,
          onSurface: ink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE9DFD2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ember, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: ember,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: ink, fontWeight: FontWeight.w900, height: 1.05),
          titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w800),
          titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w800),
          bodyMedium: TextStyle(color: bark, height: 1.4),
          bodySmall: TextStyle(color: muted, height: 1.35),
        ),
      );
}

String formatBRL(int cents) {
  final value = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $value';
}
