import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const black = Color(0xFF0A0A0A);
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF7A8699);
  static const soft = Color(0xFFF2F5F9);
  static const line = Color(0xFFE5E7EB);
  static const grey = Color(0xFFD1D5DB);
  static const green = Color(0xFF16A34A);
  static const greenBg = Color(0xFFE6F7EE);
  static const amber = Color(0xFFD97706);
  static const amberBg = Color(0xFFFEF3C7);
  static const red = Color(0xFFEA4335);
  static const redBg = Color(0xFFFDECEA);
  static const blue = Color(0xFF2563EB);
  static const blueBg = Color(0xFFE8F1FC);
}

class R {
  static const double hero = 24, card = 20, pill = 999;
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.black, primary: C.black, onPrimary: Colors.white, surface: Colors.white),
    scaffoldBackgroundColor: Colors.white,
  );
  OutlineInputBorder b([Color? c]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: c == null ? BorderSide.none : BorderSide(color: c, width: 1.5));
  return base.copyWith(
    textTheme: GoogleFonts.vazirmatnTextTheme(base.textTheme).apply(bodyColor: C.ink, displayColor: C.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0, centerTitle: true,
      foregroundColor: C.ink,
      titleTextStyle: GoogleFonts.vazirmatn(fontSize: 17, fontWeight: FontWeight.w700, color: C.ink),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: C.soft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: b(), enabledBorder: b(), focusedBorder: b(C.black), errorBorder: b(C.red),
      labelStyle: const TextStyle(color: C.muted), hintStyle: const TextStyle(color: C.muted),
    ),
    sliderTheme: const SliderThemeData(activeTrackColor: C.black, inactiveTrackColor: C.grey, thumbColor: C.black, trackHeight: 4),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.black : C.grey),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.black : Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: C.black),
    dividerColor: C.line,
  );
}
