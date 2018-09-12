import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:k2e/theme.dart';

/// Button tailored to using with [SpeedDialer].
class SpeedDialerButton {
  IconData icon;
  String text;
  int index;
  Color foregroundColor;
  Color backgroundColor;
  AnimationController controller;
  Function onPressed;

  SpeedDialerButton(
      {this.icon,
        this.text,
        this.index,
        this.controller,
        this.foregroundColor,
        this.backgroundColor,
        this.onPressed});

//  @override
//  build(BuildContext context) {
//    return new Container(
//      margin: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
//    child: new Row(
//      mainAxisAlignment: MainAxisAlignment.end,
//      children: <Widget>[
//        new Container(
//          margin: new EdgeInsets.symmetric(horizontal: 8.0),
//          child: new Chip(label:
//            Text(text,
//                textAlign: TextAlign.center,
//                overflow:TextOverflow.ellipsis,
//                style: new TextStyle(
//                    color: Colors.white,
//                    fontWeight: FontWeight.bold
//                )
//            )
//          ),
//        ),
//        new Container(
//          child: new FloatingActionButton(
//            heroTag: null,
//            backgroundColor: backgroundColor,
//            tooltip: text,
//            mini: true,
//            child: new Icon(icon, color: foregroundColor),
//            onPressed: onPressed,
//        )
//        )
//      ]
//    ),
//    );
//  }
//  @override
//  build(BuildContext context) {
//    return new Container(
//        margin: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
//        child: new Row(
//          mainAxisAlignment: MainAxisAlignment.end,
//          children: <Widget>[
//            new Container(
//                margin: new EdgeInsets.symmetric(horizontal: 8.0),
//                child: new ScaleTransition(
//                    scale: new CurvedAnimation(
//                      parent: controller,
//                      curve: new Interval(((index + 1) / 10), 1.0,
//                          curve: Curves.linear),
//                    ),
//                    child: backgroundColor!=null
//                        ?new Chip(
//                      label: new Text(
//                        text,
//                        textAlign: TextAlign.center,
//                        overflow: TextOverflow.ellipsis,
//                        style: new TextStyle(
//                            color: Colors.white, fontWeight: FontWeight.bold),
//                      ),
//                      backgroundColor: backgroundColor,
//                    ):null)),
//            new ScaleTransition(
//              scale: new CurvedAnimation(
//                parent: controller,
//                curve:
//                new Interval(((index + 1) / 10), 1.0, curve: Curves.linear),
//              ),
//              child: new FloatingActionButton(
////                  elevation: elevation,
//                  mini: true,
//                  backgroundColor: CompanyColors.accent,
////                  tooltip: text,
//                  child: new Icon(icon, color: foregroundColor),
////                  heroTag: "$index",
//                  onPressed: onPressed),
//            )
//          ],
//        ));
//  }
}

/// A FAB Speed Dialer that pops out buttons of your choice.
///
/// Consider using [SpeedDialerButton]s for ease of use.
class SpeedDialer extends StatefulWidget {
  /// Buttons that pop out upon tapping the FAB.
  List<SpeedDialerButton> children;
  IconData opened;
  IconData closed;
  Color backgroundColor;
  Duration duration;

  /// Close the speed dialer when a button is touched.
  bool closeOnSelect;

  SpeedDialer(
      {this.children,
        this.opened,
        this.closed,
        this.backgroundColor,
        this.closeOnSelect = true,
        this.duration = const Duration(milliseconds: 380)});

  @override
  State createState() => new _SpeedDialerState();
}

class _SpeedDialerState extends State<SpeedDialer>
    with TickerProviderStateMixin {
  AnimationController _controller;

  int _angle = 90;
  bool _isRotated = true;

  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  toggleOpen() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else {
      _rotate();
      _controller.reverse();
    }
  }

  closingWrap(Function func) {
    return () {
      if (widget.closeOnSelect) {
        toggleOpen();
      }
      if (func != null) func();
    };
  }

  void _rotate() {
    setState(() {
      if (_isRotated) {
        _angle = 45;
        _isRotated = false;
        _controller.forward();
      } else {
        _angle = 90;
        _isRotated = true;
        _controller.reverse();
      }
    });
  }

    Widget build(BuildContext context) {
      Color backgroundColor = CompanyColors.accent;
      Color foregroundColor = Theme
          .of(context)
          .accentColor;
//      var tempChildren = widget.children ?? [];
//      var children = tempChildren.map((SpeedDialerButton s) {
//        if (w is SpeedDialerButton) {
//          w.onPressed = closingWrap(w.onPressed);
//        }
//        return w;
//      }).toList();
      return new Container(
        alignment: Alignment.bottomRight,
        margin: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.end,
//            mainAxisSize: MainAxisSize.min,
            children: new List.generate(widget.children.length, (int index) {
              Widget child = new Container(
                height: 80.0,
//          width: 56.0,
//                margin: new EdgeInsets.symmetric(horizontal: 8.0),
                // TODO Make children not interfere with screen when invisible
                child: new ScaleTransition(
                  scale: new CurvedAnimation(
                    parent: _controller,
//                    curve: new Interval(((index + 1) / 10), 1.0,
//                        curve: Curves.linear),
                    curve: new Interval(
                        0.0, 1.0 - index / widget.children.length / 2.0,
                        curve: Curves.easeOut),
                  ),
                  child: new Container(
                      alignment: FractionalOffset.topCenter,
                      margin: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                              margin: new EdgeInsets.symmetric(horizontal: 8.0),
                              child: new ScaleTransition(
                                  scale: new CurvedAnimation(
                                    parent: _controller,
                                    curve: new Interval(((index + 1) / 10), 1.0,
                                        curve: Curves.linear),
                                  ),
                                  child: backgroundColor!=null
                                      ?new Chip(
                                    label: new Text(
                                      widget.children[index].text,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: new TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: backgroundColor,
                                  ):null)),
                          new ScaleTransition(
                            scale: new CurvedAnimation(
                              parent: _controller,
                              curve:
                              new Interval(((index + 1) / 10), 1.0, curve: Curves.linear),
                            ),
                            child: new FloatingActionButton(
                              heroTag: null,
//                  elevation: elevation,
                                mini: true,
                                backgroundColor: CompanyColors.accent,
//                  tooltip: text,
                                child: new Icon(widget.children[index].icon, color: Colors.white),
//                  heroTag: "$index",
                                onPressed: widget.children[index].onPressed),
                          )
                        ],
                      )),
                ),
              );
              return child;
            }).toList()
              ..add(
                // TODO: Support customization of this button.
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new FloatingActionButton(
                          heroTag: null,
                          backgroundColor: backgroundColor,
                          onPressed: _rotate,
                          child: new RotationTransition(
                            turns: new AlwaysStoppedAnimation(_angle / 360),
                            child: Icon(Icons.add,),)
                      ),
                    ],
                  ))
        ),
      );
    }
}