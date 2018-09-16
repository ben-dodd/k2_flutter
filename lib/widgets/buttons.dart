import 'package:flutter/material.dart';
import 'package:k2e/theme.dart';

class ScoreButton extends StatelessWidget {
  ScoreButton({
    @required this.score,
    @required this.onClick,
    this.selected,
    this.text
  });

  final int score;
  final VoidCallback onClick;
  final bool selected;
  final String text;

  Color scoreColor;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      switch (score) {
        case -1:
          scoreColor = Colors.white;
          break;
        case 0:
          scoreColor = CompanyColors.score0;
          break;
        case 1:
          scoreColor = CompanyColors.score1;
          break;
        case 2:
          scoreColor = CompanyColors.score2;
          break;
        case 3:
          scoreColor = CompanyColors.score3;
          break;
      }
    } else {
      switch (score) {
        case -1:
          scoreColor = Colors.white;
          break;
        case 0:
          scoreColor = CompanyColors.score0no;
          break;
        case 1:
          scoreColor = CompanyColors.score1no;
          break;
        case 2:
          scoreColor = CompanyColors.score2no;
          break;
        case 3:
          scoreColor = CompanyColors.score3no;
          break;
      }
    }
    return new InkWell(
      onTap: () {
        onClick();
      },
      child: new Container(
        height: 40.0,
        decoration: new BoxDecoration(
          color: scoreColor,
          border: new Border.all(color: Colors.white, width: 2.0),
          borderRadius: new BorderRadius.circular(50.0),
        ),
        child: new Center(child: (text == null) ? new Text(score.toString(),
          style: new TextStyle(fontSize: 16.0, color: Colors.white),)
          :new Text(text, style: new TextStyle(fontSize: 16.0, color: Colors.white),),
          ),
      ),
    );
  }
}