import 'dart:async';
import 'dart:convert';

import 'package:k2e/strings.dart';
import 'package:k2e/utils/custom_classes.dart';
import 'package:k2e/model/jobs/job_header.dart';
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
//
//  Future init() async{
//    return await database.init();
//  }


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
      JobHeader job = JobHeader.fromJson(jsonJob);
      wfmJobs.add(job);
    }

    wfmJobCache = wfmJobs;

    return new ParsedResponse(response.statusCode, []..addAll(wfmJobs));
  }

  /// Fetches WFM job by JobNumber (may include Completed jobs etc.)
  Future<ParsedResponse<JobHeader>> getWfmJobByJobNumber(String jobNumber) async{
    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    http.Response response = await http.get(Strings.apiRoot + 'wfm/job.php?job=' + jobNumber + '?apiKey=' + Strings.apiKey)
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

    wfmJobCache.add(JobHeader.fromJson(list[0]));

    return new ParsedResponse(response.statusCode, JobHeader.fromJson(list[0]));
  }

  ///
  /// JOBS
  ///
//
//  /// Fetches all my jobs from db
//  Future<List<JobHeader>> getMyJobs() async{
//    return database.getJobs();
//  }
//
//  /// Fetches job by jobnumber
//  Future<JobHeader> getJobByJobNumber(String jobNumber) async{
//    return database.getJobByNumber(jobNumber);
//  }

//  // Adds new job, or updates if already exists
//  Future<void> updateJob(JobHeader job) async {
//    await database.updateJob(job);
//  }

//  // Todo Create Universal function for these types of functions
//  Future<ParsedResponse<JobHeader>> getRemoteJobModifiedDate(String jobNumber) async{
//    //http request, catching error like no internet connection.
//    //If no internet is available for example response is
//    http.Response response = await http.get(Strings.apiRoot + 'job/modified.php?jobNumber=' + jobNumber + '&apiKey=' + Strings.apiKey)
//        .catchError((resp) {});
//
//    if(response == null) {
//      return new ParsedResponse(NO_INTERNET, null);
//    }
//
//    //If there was an error return an empty list
//    if(response.statusCode < 200 || response.statusCode >= 300) {
//      return new ParsedResponse(response.statusCode, null);
//    }
//    // Decode and go to the jobs list
//    print(response.body.toString());
//
//    JobHeader job = json.decode(response.body);
//
//    return new ParsedResponse(response.statusCode, job);
//  }
//
//
//  // Closes db
//  Future close() async {
//    return database.close();
//  }
}