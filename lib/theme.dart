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

  // icon colours
  static const Color iconYellow = Color(0xFFFFE070);
  static const Color iconPink = Color(0xFFFF0065);
  static const Color iconBrown = Color(0xFF995446);
  static const Color iconDGreen = Color(0xFF87CC14);
  static const Color iconLGreen = Color(0xFF74FF40);

  // icons
  static Icon asbestosIcon = new Icon(
      Icons.whatshot, color: iconYellow
  );
  static Icon methIcon = new Icon(
      Icons.lightbulb_outline, color: iconPink
  );
  static Icon noiseIcon = new Icon(
      Icons.hearing, color: iconBrown
  );
  static Icon bioIcon = new Icon(
      Icons.local_florist, color: iconDGreen
  );
//  static Icon stackIcon = new Icon(
//      Icons.hot_tub, color: iconYellow
//  );
  static Icon stackIcon = new Icon(
      Icons.filter_drama, color: iconLGreen
  );

  static Icon generalIcon = new Icon(
    Icons.assignment
  );

}