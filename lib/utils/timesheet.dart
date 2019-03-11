import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:k2e/data/wfm_manager.dart';
import 'package:k2e/strings.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart' as xml;

class TimeCounter {
  TimeCounter({
    @required this.time_start,
    @required this.wfm_user_ids,
    @required this.job_ids,
    @required this.task_id,
    this.note,
    this.billable,
  });

  DateTime time_start;
  DateTime time_end;
  List<String> wfm_user_ids;
  List<String> job_ids;
  String task_id;
  String note;
  String billable;

  Future stopTimer() async {
    this.time_end = DateTime.now();
    int minutes = this.time_end.difference(this.time_start).inMinutes;
    String date = new DateFormat('yyyyMMdd').format(this.time_end);

    String newTask;
    var task = new xml.XmlBuilder();
    task.element('Task', nest: () {
      task.element('Job', nest: () {
        task.text(this.job_ids[0]);
      });
      task.element('TaskID', nest: () {
        task.text(this.task_id);
      });
      task.element('EstimatedMinutes', nest: () {
        task.text(minutes);
      });
    });
    http.Response response = await http.post(
        Strings.wfmRoot +
            'job.api/task?apiKey=' +
            Strings.wfmApi +
            '&accountKey=' +
            Strings.wfmAccount,
        body: task.build().toString());
    if (response != null) {
      print(response.body.toString());
      newTask = xml.parse(response.body).findAllElements('ID').first.text;
      print(newTask);
    }

//    Map<String, dynamic> data;
    var timesheet = new xml.XmlBuilder();
    timesheet.element('Timesheet', nest: () {
      timesheet.element('Job', nest: () {
        timesheet.text(this.job_ids[0]);
      });
      timesheet.element('Task', nest: () {
        timesheet.text(newTask);
      });
      timesheet.element('Staff', nest: () {
        timesheet.text(this.wfm_user_ids[0]);
      });
      timesheet.element('Date', nest: () {
        timesheet.text(date);
      });
      timesheet.element('Minutes', nest: () {
        timesheet.text(minutes);
//        timesheet.text(45);
      });
      timesheet.element('Start', nest: () {
        timesheet.text(new DateFormat('HH:mm').format(this.time_start));
      });
      timesheet.element('End', nest: () {
        timesheet.text(new DateFormat('HH:mm').format(this.time_end));
      });
      timesheet.element('Note', nest: () {
        timesheet.text(this.note);
      });
    });
    var assign = new xml.XmlBuilder();
    assign.element('Job', nest: () {
      assign.element('ID', nest: () {
        assign.text(this.job_ids[0]);
      });
      assign.element('add', nest: () {
        assign.attribute('id', wfm_user_ids[0]);
        assign.attribute('task', newTask);
      });
    });

    logTime(timesheet.build(), assign.build());
  }
}
