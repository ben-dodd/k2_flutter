import 'package:flutter/material.dart';
import 'package:k2e/pages/main_page.dart';
import 'package:k2e/theme.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'K2 Environmental',
      theme: CompanyThemeData,
      home: new MainPage(),
    );
  }
}