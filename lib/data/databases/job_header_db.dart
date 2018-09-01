//import 'dart:async';
//import 'dart:io';
//import 'package:path/path.dart';
//import 'package:sqflite/sqflite.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:k2e/model/jobs/job_header.dart';
//
//class JobHeaderDatabase {
//  static final JobHeaderDatabase _jobHeaderDatabase = new JobHeaderDatabase._internal();
//
//  final String tableName = "Jobs";
//
//  Database db;
//
//  bool didInit = false;
//
//  static JobHeaderDatabase get() {
//    return _jobHeaderDatabase;
//  }
//
//  JobHeaderDatabase._internal();
//
//  /// Use this method to access the database, because initialization of the database (it has to go through the method channel)
//  Future<Database> _getDb() async{
//    if(!didInit) await _init();
//    return db;
//  }
//
//  Future init() async {
//    return await _init();
//  }
//
//  // Create table
//  Future _init() async {
//    // Get a location using path_provider
//    Directory documentsDirectory = await getApplicationDocumentsDirectory();
//    String path = join(documentsDirectory.path, "job.db");
//    db = await openDatabase(path, version: 1,
//        onCreate: (Database db, int version) async {
//          // When creating the db, create the table
//          await db.execute(
//              "CREATE TABLE $tableName ("
//                  "jobNumber STRING PRIMARY KEY,"
//                  "address TEXT,"
//                  "description TEXT,"
//                  "clientName TEXT,"
//                  "state TEXT,"
//                  "type TEXT,"
//                  "imagePath TEXT,"
//                  "lastModified TEXT,"
//                  "lastSynced TEXT"
//                  ")");
//        });
//    didInit = true;
//  }
//
//  /// Get a Job by its jobNumber, if there is not entry for that jobNumber, returns null.
//  Future<JobHeader> getJobByNumber(String jobNumber) async{
//    var db = await _getDb();
//    var result = await db.rawQuery('SELECT * FROM $tableName WHERE jobNumber = "$jobNumber"');
//    if(result.length == 0)return null;
//    return new JobHeader.fromJson(result[0]);
//  }
//
//  /// Get all jobs by a list of jobnumbers, will return a list with all the jobs found
//  Future<List<JobHeader>> getJobsByNumbers(List<String> jobNumbers) async{
//    var db = await _getDb();
//    // Building SELECT * FROM TABLE WHERE ID IN (id1, id2, ..., idn)
//    var jobNumbersString = jobNumbers.map((it) => '"$it"').join(',');
//    var result = await db.rawQuery('SELECT * FROM $tableName WHERE jobNumber IN ($jobNumbersString)');
//    List<JobHeader> jobs = [];
//    for(Map<String, dynamic> item in result) {
//      jobs.add(new JobHeader.fromJson(item));
//    }
//    return jobs;
//  }
//
//  // Get all jobs in database
//  Future<List<JobHeader>> getJobs() async{
//    var db = await _getDb();
//    var result = await db.rawQuery('SELECT * FROM $tableName');
//    List<JobHeader> jobs = [];
//    for (Map<String, dynamic> item in result) {
//      jobs.add(new JobHeader.fromJson(item));
//      print(jobs.length.toString());
//    }
//    return jobs;
//  }
//
//  /// Inserts or replaces the job.
//  Future updateJob(JobHeader job) async {
//    var db = await _getDb();
//    await db.rawInsert(
//        'INSERT OR REPLACE INTO '
//            '$tableName(jobNumber, address, description, clientName, state, type, imagePath, lastModified, lastSynced)'
//            ' VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
//        [job.jobNumber, job.address, job.description, job.clientName, job.state, job.type, job.imagePath, job.lastModified, job.lastSynced]);
//    print('Job updated ' + job.jobNumber);
//  }
//
//  // Close db
//  Future close() async {
//    var db = await _getDb();
//    return db.close();
//  }
//
//}