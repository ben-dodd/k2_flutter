import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:k2e/model/jobs/job_object.dart';

class JobDatabase {
  static final JobDatabase _jobDatabase = new JobDatabase._internal();

  final String tableName = "Jobs";

  Database db;

  bool didInit = false;

  static JobDatabase get() {
    return _jobDatabase;
  }

  JobDatabase._internal();

  /// Use this method to access the database, because initialization of the database (it has to go through the method channel)
  Future<Database> _getDb() async{
    if(!didInit) await _init();
    return db;
  }

  Future init() async {
    return await _init();
  }

  // Create table
  Future _init() async {
    // Get a location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "job.db");
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              "CREATE TABLE $tableName ("
                  "${Job.db_job_number} STRING PRIMARY KEY,"
                  "${Job.db_address} TEXT,"
                  "${Job.db_description} TEXT,"
                  "${Job.db_client_name} TEXT,"
                  "${Job.db_state} TEXT,"
                  "${Job.db_type} TEXT,"
                  "${Job.db_last_modified} TEXT"
                  ")");
        });
    didInit = true;
  }

  /// Get a Job by its jobNumber, if there is not entry for that jobNumber, returns null.
  Future<Job> getJobByNumber(String jobNumber) async{
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE ${Job.db_job_number} = "$jobNumber"');
    if(result.length == 0)return null;
    return new Job.fromMap(result[0]);
  }

  /// Get all jobs by a list of jobnumbers, will return a list with all the jobs found
  Future<List<Job>> getJobsByNumbers(List<String> jobNumbers) async{
    var db = await _getDb();
    // Building SELECT * FROM TABLE WHERE ID IN (id1, id2, ..., idn)
    var jobNumbersString = jobNumbers.map((it) => '"$it"').join(',');
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE ${Job.db_job_number} IN ($jobNumbersString)');
    List<Job> jobs = [];
    for(Map<String, dynamic> item in result) {
      jobs.add(new Job.fromMap(item));
    }
    return jobs;
  }

  // Get all jobs in database
  Future<List<Job>> getJobs() async{
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $tableName');
    List<Job> jobs = [];
    for (Map<String, dynamic> item in result) {
      jobs.add(new Job.fromMap(item));
      print(jobs.length.toString());
    }
    return jobs;
  }

  /// Inserts or replaces the job.
  Future updateJob(Job job) async {
    var db = await _getDb();
    await db.rawInsert(
        'INSERT OR REPLACE INTO '
            '$tableName(${Job.db_job_number}, ${Job.db_address}, ${Job.db_description}, ${Job.db_client_name}, ${Job.db_state}, ${Job.db_type}, ${Job.db_last_modified})'
            ' VALUES(?, ?, ?, ?, ?, ?, ?)',
        [job.jobNumber, job.address, job.description, job.clientName, job.state, job.type, job.lastModified]);
    print('Job updated ' + job.jobNumber);
  }

  // Close db
  Future close() async {
    var db = await _getDb();
    return db.close();
  }

}