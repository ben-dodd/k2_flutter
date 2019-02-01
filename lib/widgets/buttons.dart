import 'package:flutter/material.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/tooltips.dart';
import 'package:k2e/widgets/customdialog.dart';

class ScoreButton extends StatelessWidget {
  ScoreButton({
    @required this.score,
    @required this.onClick,
    this.showHint,
    this.selected,
    this.text,
    this.tooltip,
    this.bordercolor,
    this.radius,
    this.textcolor,
    this.dialogHeight,
  });

  final int score;
  final VoidCallback onClick;
  final VoidCallback showHint;
  final bool selected;
  final String text;
  final ToolTip tooltip;
  final Color bordercolor;
  final double radius;
  final double dialogHeight;
  Color textcolor;

  Color scoreColor;

  // TODO OnLongPress show tooltip e.g. what the score means

  @override
  Widget build(BuildContext context) {
    if (textcolor == null) textcolor = Colors.white;
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
    return new Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      child: InkWell(
      onTap: () {
        onClick();
      },
      onLongPress: () {
        if (tooltip != null) {
          showDialog<Null>(
              context: context,
              builder: (BuildContext context) {
                return new CustomAlertDialog(
                    title: new Text(tooltip.title, style: Styles.h2),
                    content: new Container(
                      decoration: new BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.white,
                        borderRadius: new BorderRadius.all(new Radius.circular(200.0))
                      ),
                      height: dialogHeight != null ? dialogHeight : 200.0,
                      child: Column(
                        children: <Widget>[
                          Container(child: Text(tooltip.tip, style: Styles.body), alignment: Alignment.bottomLeft,),
                          Container(child: Text(tooltip.subtip, style: Styles.comment), alignment: Alignment.bottomLeft,),
                        ])
                    ),
                );
              }
          );
        }
      },
      child: new Container(
        height: 40.0,
        decoration: new BoxDecoration(
          color: scoreColor,
          border: new Border.all(color: (bordercolor != null) ? bordercolor : Colors.black12, width: 2.0),
          borderRadius: (radius != null) ? new BorderRadius.circular(radius) : new BorderRadius.circular(50.0),
        ),
        child: new Center(child: (text == null) ? new Text(score.toString(),
          style: new TextStyle(fontSize: 16.0, color: textcolor),)
          :new Text(text, style: new TextStyle(fontSize: 16.0, color: textcolor),),
          ),
        )
      )
    );
  }
}

class SelectButton extends StatelessWidget {
  SelectButton({
    @required this.onClick,
    this.score,
    this.onLongPress,
    this.selected,
    this.text,
    this.tooltip,
    this.bgcolor,
    this.bordercolor,
    this.radius,
    this.textcolor
  });

  final int score;
  final VoidCallback onClick;
  final VoidCallback onLongPress;
  final bool selected;
  final String text;
  final ToolTip tooltip;
  final Color bordercolor;
  Color bgcolor;
  final double radius;
  Color textcolor;

  @override
  Widget build(BuildContext context) {
    selected ? bgcolor = CompanyColors.accentRippled : bgcolor = Colors.white;
    if (textcolor == null) selected ? textcolor = Colors.black87 : textcolor = Colors.black12;
    return new Container(
        padding: EdgeInsets.symmetric(horizontal: 6.0),
        child: InkWell(
            onTap: () {
              onClick();
            },
            onLongPress: () {
              if (tooltip != null) {
                showDialog<Null>(
                    context: context,
                    builder: (BuildContext context) {
                      return new AlertDialog(
                          title: new Text(tooltip.title),
                          content: Container(
                              height: 120.0,
                              child: Column(
                                  children: <Widget>[
                                    Container(child: Text(tooltip.tip), alignment: Alignment.bottomLeft,),
                                    Container(child: Text(tooltip.subtip, style: Styles.comment), alignment: Alignment.bottomLeft,),
                                  ])
                          ));
                    }
                );
              }
            },
            child: new Container(
              height: 40.0,
              decoration: new BoxDecoration(
                color: bgcolor,
                border: new Border.all(color: (bordercolor != null) ? bordercolor : Colors.black12, width: 2.0),
                borderRadius: (radius != null) ? new BorderRadius.circular(radius) : new BorderRadius.circular(0.0),
              ),
              child: new Center(child: (text == null) ? new Text(score.toString(),
                style: new TextStyle(fontSize: 16.0, color: textcolor),)
                  :new Text(text, style: new TextStyle(fontSize: 16.0, color: textcolor),),
              ),
            )
        )
    );
  }
}