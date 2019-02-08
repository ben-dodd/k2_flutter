
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/strings.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/utils/timesheet.dart';
import 'package:k2e/widgets/pulsecard.dart';

// The base page for any type of job. Shows address, has cover photo,

class LogTimeTab extends StatefulWidget {
  LogTimeTab() : super();
  @override
  _LogTimeTabState createState() => new _LogTimeTabState();
}

class _LogTimeTabState extends State<LogTimeTab> {
  @override
  void initState() {
//    if (DataManager.get().currentTimeCounter != null) selectedTask = DataManager.get().currentTimeCounter.task_id;
    super.initState();
  }

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
                      task_id: Strings.taskTravel,
                      onCardClick: () {
                        handleClick(Strings.taskTravel);
                      },
                      onCardLongPress: () {
                        // TODO longpress: Share with other job numbers, add other site tech
                      },
                  ),
                  PulseCard(
                    icon: Icon(Icons.build,size: 24.0,),
                    text: 'Site Work',
                    task_id: Strings.taskSiteWork,
                    onCardClick: () {
                      handleClick(Strings.taskSiteWork);
                    },
                    onCardLongPress: () {
                      // TODO: longpress Do SSSP, add site tech
                    },
                  ),
                  PulseCard(
                    icon: Icon(Icons.colorize,size: 24.0,),
                    text: 'Analysis',
                    task_id: Strings.taskAnalysis,
                    onCardClick: () {
                      handleClick(Strings.taskAnalysis);
                    },
                    onCardLongPress: () {

                    },
                  ),
                  PulseCard(
                    icon: Icon(Icons.insert_chart,size: 24.0,),
                    text: 'Report',
                    task_id: Strings.taskReport,
                    onCardClick: () {
                      handleClick(Strings.taskReport);
                    },
                    onCardLongPress: () {

                    },
                  ),
                  PulseCard(
                    icon: Icon(Icons.check_circle,size: 24.0,),
                    text: 'Review',
                    task_id: Strings.taskReview,
                    onCardClick: () {
                      handleClick(Strings.taskReview);
                    },
                    onCardLongPress: () {

                    },
                  ),
                  PulseCard(
                    icon: Icon(Icons.assignment_ind,size: 24.0,),
                    text: 'KTP',
                    task_id: Strings.taskKTP,
                    onCardClick: () {
                      handleClick(Strings.taskKTP);
                    },
                    onCardLongPress: () {

                    },
                  ),
                ]
            )
        )
    );
  }

  void handleClick(String task_id) {
    if (DataManager.get().currentTimeCounter != null) {
      if (DataManager.get().currentTimeCounter.task_id == task_id) {
        print('turn off this task');
        DataManager.get().currentTimeCounter.stopTimer();
        DataManager.get().currentTimeCounter = null;
      } else {
        print('turn off another task, start this task');
        DataManager.get().currentTimeCounter.stopTimer();
        DataManager.get().currentTimeCounter = new TimeCounter(
          task_id: task_id,
          time_start: new DateTime.now(),
          job_ids: new List<String>.filled(1, DataManager.get().currentJobNumber),
          wfm_user_ids: new List<String>.filled(1,'403502'),
          note: '',
        );
      }
    } else {
      print('start this task');
      DataManager.get().currentTimeCounter = new TimeCounter(
          task_id: task_id,
          time_start: new DateTime.now(),
          job_ids: new List<String>.filled(1, DataManager.get().currentJobNumber),
          wfm_user_ids: new List<String>.filled(1,'403502'),
          note: '',
      );
    }
  }

  void _handleLongPress() {

  }
}