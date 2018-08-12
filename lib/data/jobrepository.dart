import 'dart:async';
import 'dart:convert';

import 'package:k2e/utils/custom_classes.dart';
import 'package:k2e/data/jobdatabase.dart';
import 'package:k2e/model/jobs/job_object.dart';
import 'package:http/http.dart' as http;

final int NO_INTERNET = 404;

class JobRepository {
  String apiKey = 'BfqKcOR6tcMtFPCH7MrmHoaANEIJ5grs'; // k2 key
  String apiRoot = 'https://api.k2.co.nz/v1/';

  static final JobRepository _repo = new JobRepository._internal();

  JobDatabase database;

  List<Job> wfmJobCache = new List();
  List<Job> myJobCache = new List();
  Job currentJob;

  static JobRepository get() {
    return _repo;
  }

  JobRepository._internal() {
    database = JobDatabase.get();
  }

  Future init() async{
    return await database.init();
  }

  /// Fetches all WFM jobs
  Future<ParsedResponse<List<Job>>> getAllJobs() async{
    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    http.Response response = await http.get(apiRoot + 'wfm/job.php?apiKey=' + apiKey)
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

    List<Job> wfmJobs = new List();

    for(dynamic jsonJob in list) {
      Job job = Job.fromJson(jsonJob);
      wfmJobs.add(job);
    }

    wfmJobCache = wfmJobs;

    return new ParsedResponse(response.statusCode, []..addAll(wfmJobs));
  }

  /// Fetches all my jobs
  Future<List<Job>> getMyJobs() async{
    database.getJobs()
      .then((jobs) =>
        myJobCache = jobs);
    return myJobCache;
  }

  /// Fetches job by jobnumber
  Future<Job> getJobByJobNumber(String jobNumber) async{
    return database.getJobByNumber(jobNumber);
  }

  // Adds new job, or updates if already exists
  Future<void> updateJob(Job job) async {
    await database.updateJob(job);
  }

  // Closes db
  Future close() async {
    return database.close();
  }
}