import 'package:flutter/material.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/buttons.dart';

class HeaderText extends StatelessWidget {
  HeaderText({Key key, @required this.text}) : super(key: key);

  final String text;


  @override
  Widget build(BuildContext context) {
    return Container(
            alignment: Alignment.bottomLeft,
            height: 25.0,
            margin: EdgeInsets.only(
                left: 12.0, bottom: 2.0),
            child: new Text(
              text,
              style: Styles.h3,
            ));
  }
}


