import 'dart:async';
import 'dart:convert';

import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/jobheader.dart';
import 'package:k2e/strings.dart';
import 'package:k2e/utils/custom_classes.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

final int NO_INTERNET = 404;

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

    DataManager.get().wfmJobCache = wfmJobs;

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

    DataManager.get().wfmJobCache.add(JobHeader.fromMap(list[0]));

    return new ParsedResponse(response.statusCode, JobHeader.fromMap(list[0]));
  }

  Future logTime(xml.XmlDocument TimeSheet, xml.XmlDocument Assign) async{
          http.put(Strings.wfmRoot + 'job.api/assign?apiKey=' + Strings.wfmApi + '&accountKey=' + Strings.wfmAccount, body: Assign.toString())
              .then((ass) {
                if (ass != null) {
                    print(ass.body.toString());
                    http.post(Strings.wfmRoot + 'time.api/add?apiKey=' + Strings.wfmApi + '&accountKey=' + Strings.wfmAccount, body: TimeSheet.toString())
                        .then((time) {
//                          if(response == null) {
//                            print ('null reponse from time');
//                            return new ParsedResponse(NO_INTERNET, null);
//                          }

                          //If there was an error return an empty list
//                          if(response.statusCode < 200 || response.statusCode >= 300) {
//                            return new ParsedResponse(response.statusCode, null);
//                          }
                          // Decode and go to the jobs list
                          print("ADD RESPONSE: " + time.body.toString());

//                          return new ParsedResponse(response.statusCode, json.decode(response.body));
                    });
                } else print ('null reponse from assign');
          });

    print (Strings.wfmRoot + 'time.api/add?apiKey=' + Strings.wfmApi + '&accountKey=' + Strings.wfmAccount);
    print(TimeSheet);
    print (Strings.wfmRoot + 'job.api/assign?apiKey=' + Strings.wfmApi + '&accountKey=' + Strings.wfmAccount);
    print(Assign);
  }