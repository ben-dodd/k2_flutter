import 'dart:async';
import 'dart:io';

import 'package:k2e/model/entities/samples/sample_asbestos_bulk.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SampleAsbestosBulkDatabase {
  static final SampleAsbestosBulkDatabase _SampleAsbestosBulkDatabase = new SampleAsbestosBulkDatabase._internal();

  final String tableName = "SampleAsbestosBulk";

  Database db;

  bool didInit = false;

  static SampleAsbestosBulkDatabase get() {
    return _SampleAsbestosBulkDatabase;
  }

  SampleAsbestosBulkDatabase._internal();

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
    String path = join(documentsDirectory.path, "sampleasbestosbulk.db");
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              "CREATE TABLE $tableName ("
                  "uuid STRING PRIMARY KEY,"
                  "asbestosItemUuid TEXT,"
                  "description TEXT,"
                  "material TEXT,"
                  "jobNumber TEXT,"
                  "sampleNumber INTEGER,"
                  "clientName TEXT,"
                  "address TEXT,"
                  "samplerUuid TEXT,"
                  "siteNotes TEXT,"
                  "sampleDateTime TEXT,"
                  "analysisResultUuid TEXT,"
                  "analysisResult TEXT,"
                  "imagePath TEXT,"
                  "receivedWeight REAL,"
                  "dryWeight REAL,"
                  "resultVersion INTEGER,"
                  "hasSynced INTEGER"
                  ")");
        });
    didInit = true;
  }

  /// Get all superrooms linked to the jobNumber
  Future<List<SampleAsbestosBulk>> getSamplesByJobNumber(String jobNumber) async{
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE jobNumber = "$jobNumber"');
    if(result.length == 0)return null;
    List<SampleAsbestosBulk> samples = [];
    for(Map<String, dynamic> item in result) {
      samples.add(new SampleAsbestosBulk.fromJson(item));
    }
    return samples;
  }

  /// Inserts or replaces the job.
  Future updateSample(SampleAsbestosBulk sample) async {
    var db = await _getDb();
    await db.rawInsert(
        'INSERT OR REPLACE INTO '
            '$tableName('
            'uuid,'
            'asbestosItemUuid,'
            'description,'
            'material,'
            'jobNumber,'
            'sampleNumber,'
            'clientName,'
            'address,'
            'samplerUuid,'
            'siteNotes,'
            'sampleDateTime,'
            'analysisResultUuid,'
            'analysisResult,'
            'imagePath,'
            'receivedWeight,'
            'dryWeight,'
            'resultVersion,'
            'hasSynced)'
            ' VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [sample.uuid,
        sample.asbestosItemUuid,
        sample.description,
        sample.material,
        sample.jobNumber,
        sample.sampleNumber,
        sample.clientName,
        sample.address,
        sample.samplerUuid,
        sample.siteNotes,
        sample.sampleDateTime,
        sample.analysisResultUuid,
        sample.analysisResult,
        sample.imagePath,
        sample.receivedWeight,
        sample.dryWeight,
        sample.resultVersion,
        sample.hasSynced]);
    print('Sample updated ' + sample.jobNumber + '-' + sample.sampleNumber.toString() + ': ' + sample.description);
  }

  // Close db
  Future close() async {
    var db = await _getDb();
    return db.close();
  }

}