import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:k2e/data/databases/sample_asbestos_bulk_db.dart';
import 'package:k2e/model/samples/sample_asbestos_bulk.dart';
import 'package:k2e/model/jobs/job_header.dart';
import 'package:k2e/strings.dart';
import 'package:k2e/utils/custom_classes.dart';

final int NO_INTERNET = 404;

class SampleAsbestosBulkRepo {

  static final SampleAsbestosBulkRepo _repo = new SampleAsbestosBulkRepo._internal();

  SampleAsbestosBulkDatabase database;


  JobHeader currentJob; // this holds the job object for the currently viewed job
//  List<Samples>

  static SampleAsbestosBulkRepo get() {
    return _repo;
  }

  SampleAsbestosBulkRepo._internal() {
    database = SampleAsbestosBulkDatabase.get();
  }

  Future init() async{
    return await database.init();
  }

  /// Gets all samples that have not been analysed
  Future<ParsedResponse<List<SampleAsbestosBulk>>> getAllCurrentSamples() async{
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

    List<SampleAsbestosBulk> samples = new List();

    for(dynamic jsonJob in list) {
      SampleAsbestosBulk sample = SampleAsbestosBulk.fromJson(jsonJob);
      samples.add(sample);
    }

    return new ParsedResponse(response.statusCode, []..addAll(samples));
  }

  /// Get all samples related to job
  Future<List<SampleAsbestosBulk>> getSamplesByJobNumber(String jobNumber) async {
    return database.getSamplesByJobNumber(jobNumber);
  }


  /// Get all samples with sample date between


  // Adds new job, or updates if already exists
  Future<void> updateSample(SampleAsbestosBulk sample) async {
    await database.updateSample(sample);
    print(sample.jobNumber + '-' + sample.sampleNumber.toString() + ' updated!');
  }

  // Closes db
  Future close() async {
    return database.close();
  }
}