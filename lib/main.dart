import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:k2e/pages/login_page.dart';
import 'package:k2e/pages/main_page.dart';
import 'package:k2e/pages/splash_page.dart';
import 'package:k2e/theme.dart';

Future<void> main() async {
  runApp(new MyApp());
}

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

//  Widget _handleCurrentScreen() {
//    return new StreamBuilder<FirebaseUser>(
//      stream: FirebaseAuth.instance.onAuthStateChanged,
//      builder: (BuildContext context, snapshot) {
//        if (snapshot.connectionState == ConnectionState.waiting) {
//          return new SplashPage();
//        } else {
//          if (snapshot.hasData) {
//            return new MainPage();
//          }
//          return new LoginPage();
//        }
//      }
//    );
//  }
}