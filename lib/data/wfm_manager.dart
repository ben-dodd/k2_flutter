import 'dart:async';
import 'dart:convert';

import 'package:k2e/model/jobheader.dart';
import 'package:k2e/strings.dart';
import 'package:k2e/utils/custom_classes.dart';
import 'package:http/http.dart' as http;

final int NO_INTERNET = 404;

class WfmManager {

  static final WfmManager _wfm = new WfmManager._internal();

//  JobHeaderDatabase database;

  List<JobHeader> wfmJobCache = new List(); // this holds all jobs gathered from the last WFM api request
  List<JobHeader> myJobCache = new List(); // this holds all jobs in the local database
  JobHeader currentJob; // this holds the job object for the currently viewed job
//  List<Samples>

  static WfmManager get() {
    return _wfm;
  }

  WfmManager._internal() {
//    database = JobHeaderDatabase.get();
  }

  ///
  /// WFM JOBS
  ///

  /// Fetches all current WFM jobs
  Future<ParsedResponse<List<JobHeader>>> getAllWfmJobs() async{
    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    http.Response response = await http.get(Strings.apiRoot + 'wfm/job.php?apiKey=' + Strings.apiKey)
        .catchError((resp) {});

    if(response == null) {
      return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if(response.statusCode < 200 || response.statusCode >= 300) {
      return new ParsedResponse(response.statusCode, []);
    }
    // Decode and go to the jobs list
    print(response.body.toString());
    List<dynamic> list = json.decode(response.body);

    List<JobHeader> wfmJobs = new List();

    for(dynamic jsonJob in list) {
      JobHeader job = JobHeader.fromMap(jsonJob);
      print (jsonJob.toString() + ' = ');
      wfmJobs.add(job);
    }

    wfmJobCache = wfmJobs;

    return new ParsedResponse(response.statusCode, []..addAll(wfmJobs));
  }

  /// Fetches WFM job by JobNumber (may include Completed jobs etc.)
  Future<ParsedResponse<JobHeader>> getWfmJobByJobNumber(String jobnumber) async{
    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    http.Response response = await http.get(Strings.apiRoot + 'wfm/job.php?job=' + jobnumber + '?apiKey=' + Strings.apiKey)
        .catchError((resp) {});

    if(response == null) {
      return new ParsedResponse(NO_INTERNET, null);
    }

    //If there was an error return an empty list
    if(response.statusCode < 200 || response.statusCode >= 300) {
      return new ParsedResponse(response.statusCode, null);
    }
    // Decode and go to the jobs list
    print(response.body.toString());
    List<dynamic> list = json.decode(response.body);

    wfmJobCache.add(JobHeader.fromMap(list[0]));

    return new ParsedResponse(response.statusCode, JobHeader.fromMap(list[0]));
  }
}