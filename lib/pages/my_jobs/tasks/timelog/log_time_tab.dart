import 'package:flutter/material.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/pulsecard.dart';

// The base page for any type of job. Shows address, has cover photo,

class LogTimeTab extends StatefulWidget {
  LogTimeTab() : super();
  @override
  _LogTimeTabState createState() => new _LogTimeTabState();
}

class _LogTimeTabState extends State<LogTimeTab> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return new Scaffold(
        body:
        new Container(
            padding: new EdgeInsets.all(24.0),
            alignment: Alignment.center,
            child: Column(
                children: <Widget> [
                  Text('Log Time',
                  style: Styles.h1),
                  PulseCard(
                      icon: Icon(Icons.directions_car,size: 24.0,),
                      text: 'Travel',
                      onCardClick: () {

                      },
                      onCardLongPress: () {
                        // TODO longpress: Share with other job numbers, add other site tech
                      },
                  ),
                  PulseCard(
                    icon: Icon(Icons.build,size: 24.0,),
                    text: 'Site Work',
                    onCardClick: () {

                    },
                    onCardLongPress: () {
                      // TODO: longpress Do SSSP, add site tech
                    },
                  ),
                  PulseCard(
                    icon: Icon(Icons.colorize,size: 24.0,),
                    text: 'Analysis',
                    onCardClick: () {

                    },
                    onCardLongPress: () {

                    },
                  ),
                  PulseCard(
                    icon: Icon(Icons.insert_chart,size: 24.0,),
                    text: 'Report',
                    onCardClick: () {

                    },
                    onCardLongPress: () {

                    },
                  ),
                  PulseCard(
                    icon: Icon(Icons.check_circle,size: 24.0,),
                    text: 'Review',
                    onCardClick: () {

                    },
                    onCardLongPress: () {

                    },
                  ),
                  PulseCard(
                    icon: Icon(Icons.assignment_ind,size: 24.0,),
                    text: 'KTP',
                    onCardClick: () {

                    },
                    onCardLongPress: () {

                    },
                  ),
                ]
            )
        )
    );
  }
}