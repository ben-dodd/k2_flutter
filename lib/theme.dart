import 'package:flutter/material.dart';

final ThemeData CompanyThemeData = new ThemeData(
  brightness: Brightness.light,
  primaryColor: CompanyColors.colorPrimaryDark,
  primaryColorBrightness: Brightness.dark,
  accentColor: CompanyColors.accent,
  accentColorBrightness: Brightness.dark,
);

class CompanyColors {
  static const Color colorPrimaryLight = Color(0xFF3D9976);
  static const Color colorPrimaryDark = Color(0xFF006D44);
  static const Color accent = Color(0xFFFF2D00);
  static const Color accentPressed = Color(0xFFD32500);
  static const Color accentRippled = Color(0xFFFFA28E);
}