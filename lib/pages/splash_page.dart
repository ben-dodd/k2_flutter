import 'package:flutter/material.dart';
import 'package:k2e/theme.dart';

class SplashPage extends StatelessWidget {
  SplashPage() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CompanyColors.iconLGreen,
      margin: EdgeInsets.all(64.0),
      child: Text('K2')
      );
  }
}
