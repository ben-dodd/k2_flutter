import 'package:flutter/material.dart';
import 'package:k2e/theme.dart';

class Styles {
  static TextStyle h1 = new TextStyle(
    color: CompanyColors.accentRippled,
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
  );

  static TextStyle h2 = new TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );

  static TextStyle h3 = new TextStyle(
//    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    fontSize: 14.0,
  );

  static TextStyle body = new TextStyle(
    fontSize: 16.0,
  );

  static TextStyle sampleNumber = new TextStyle(
    fontWeight: FontWeight.bold,
    color: CompanyColors.accent,
    fontSize: 16.0,
  );

  static TextStyle loading = new TextStyle(fontSize: 16.0, color: Colors.black);

  static TextStyle comment = new TextStyle(
    color: Colors.black38,
    fontStyle: FontStyle.italic,
    fontSize: 14.0,
  );

  static TextStyle label = new TextStyle(
    color: Colors.black54,
    fontSize: 12.0,
  );

  static TextStyle labelDisabled = new TextStyle(
    color: Colors.black26,
    fontSize: 12.0,
  );

  static TextStyle acmCard = new TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
  );

  static TextStyle logButton = new TextStyle(
    fontSize: 16.0,
  );
}
