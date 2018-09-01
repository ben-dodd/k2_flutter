//import 'dart:async';
//import 'dart:io';
//import 'package:k2e/model/entities/materials/acm.dart';
//import 'package:path/path.dart';
//import 'package:sqflite/sqflite.dart';
//import 'package:path_provider/path_provider.dart';
//
//class AcmDatabase {
//  static final AcmDatabase _ACMDatabase = new AcmDatabase._internal();
//
//  final String tableName = "ACM";
//
//  Database db;
//
//  bool didInit = false;
//
//  static AcmDatabase get() {
//    return _ACMDatabase;
//  }
//
//  AcmDatabase._internal();
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
//    String path = join(documentsDirectory.path, "acm.db");
//    db = await openDatabase(path, version: 1,
//        onCreate: (Database db, int version) async {
//          // When creating the db, create the table
//          await db.execute(
//              "CREATE TABLE $tableName ("
//                  "uuid STRING PRIMARY KEY,"
//                  "displayName TEXT,"
//                  "item TEXT,"
//                  "material TEXT,"
//                  "roomUuid TEXT,"
//                  "taskUuid TEXT,"
//                  "sampleUuid TEXT,"
//                  "privateNote TEXT,"
//                  "reportNote TEXT,"
//                  "reasonForNotSampling TEXT,"
//                  "includeInReport INTEGER,"
//                  "genericInReport INTEGER,"
//                  "idLevel INTEGER,"
//                  "canBeIdentified INTEGER,"
//                  "isNoAccess INTEGER,"
//                  "presumeAsbestosType TEXT,"
//                  "accessibility TEXT,"
//                  "presumeAsbestosType TEXT,"
//                  "extentDesc TEXT,"
//                  "extentAmount TEXT,"
//                  "damageDesc TEXT,"
//                  "surfaceDesc TEXT,"
//                  "mrProductScore INTEGER,"
//                  "mrDamageScore INTEGER,"
//                  "mrSurfaceScore INTEGER,"
//                  "prActivityMain INTEGER,"
//                  "prActivitySecond INTEGER,"
//                  "prDisturbanceLocation INTEGER,"
//                  "prDisturbanceAccessibility INTEGER,"
//                  "prDisturbanceExtent INTEGER,"
//                  "prExposureOccupants INTEGER,"
//                  "prExposureUseFreq INTEGER,"
//                  "prExposureAvgTime INTEGER,"
//                  "prMaintenanceType INTEGER,"
//                  "prMaintenanceFreq INTEGER,"
//                  "hasSynced INTEGER"
//                  ")");
//        });
//    didInit = true;
//  }
//
//  /// Get all superrooms linked to the jobNumber
//  Future<List<ACM>> getAcmByJobNumber(String jobNumber) async{
//    var db = await _getDb();
//    var result = await db.rawQuery('SELECT * FROM $tableName WHERE jobNumber = "$jobNumber"');
//    if(result.length == 0)return null;
//    List<ACM> acm = [];
//    for(Map<String, dynamic> item in result) {
//      acm.add(new ACM.fromJson(item));
//    }
//    return acm;
//  }
//
//  /// Inserts or replaces the job.
//  Future updateAcm(ACM acm) async {
//    var db = await _getDb();
//    await db.rawInsert(
//        'INSERT OR REPLACE INTO '
//            '$tableName('
//            'uuid,'
//            'displayName,'
//            'item,'
//            'material,'
//            'roomUuid,'
//            'taskUuid,'
//            'sampleUuid,' // 'presume as' if presumed
//            'privateNote,' // note about item, not to be included in report
//            'reportNote,' // comment or note to put in report
//            'reasonForNotSampling,' // note if a presumed item
//
//            // Report settings
//            'includeInReport,'
//            'genericInReport,'
//
//            // Presumed
//            'idLevel,' // 0 presumed, 1 strongly presumed, 2 sampled
//            'canBeIdentified,'
//            'isNoAccess,'
//            'presumeAsbestosType,'
//
//            // Accessibility
//            'accessibility,'
//
//            // Extent
//            'extentDesc,'
//            'extentAmount,'
//
//            // Damage/Surface
//            'damageDesc,'
//            'surfaceDesc,'
//
//            'mrProductScore,'
//            'mrDamageScore,'
//            'mrSurfaceScore,'
//
//            // priority risk assessment
//            // activity
//            'prActivityMain,'
//            'prActivitySecond,'
//
//            // disturbance
//            'prDisturbanceLocation,'
//            'prDisturbanceAccessibility,'
//            'prDisturbanceExtent,'
//
//            // exposure
//            'prExposureOccupants,'
//            'prExposureUseFreq,'
//            'prExposureAvgTime,'
//
//            // maintenance
//            'prMaintenanceType,'
//            'prMaintenanceFreq,'
//            'hasSynced)'
//            ' VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
//        [acm.uuid,
//        acm.displayName, // can be auto generated from item and material or altered to something less verbose
//        acm.item,
//        acm.material,
//        acm.roomUuid,
//        acm.taskUuid,
//        acm.sampleUuid, // 'presume as' if presumed
//        acm.privateNote, // note about item, not to be included in report
//        acm.reportNote, // comment or note to put in report
//        acm.reasonForNotSampling, // note if a presumed item
//
//        // Report settings
//        acm.includeInReport,
//        acm.genericInReport,
//
//        // Presumed
//        acm.idLevel, // 0 presumed, 1 strongly presumed, 2 sampled
//        acm.canBeIdentified,
//        acm.isNoAccess,
//        acm.presumeAsbestosType,
//
//        // Accessibility
//        acm.accessibility,
//
//        // Extent
//        acm.extentDesc,
//        acm.extentAmount,
//
//        // Damage/Surface
//        acm.damageDesc,
//        acm.surfaceDesc,
//
//        acm.mrProductScore,
//        acm.mrDamageScore,
//        acm.mrSurfaceScore,
//
//        // priority risk assessment
//        // activity
//        acm.prActivityMain,
//        acm.prActivitySecond,
//
//        // disturbance
//        acm.prDisturbanceLocation,
//        acm.prDisturbanceAccessibility,
//        acm.prDisturbanceExtent,
//
//        // exposure
//        acm.prExposureOccupants,
//        acm.prExposureUseFreq,
//        acm.prExposureAvgTime,
//
//        // maintenance
//        acm.prMaintenanceType,
//        acm.prMaintenanceFreq,
//        acm.hasSynced]);
//    print('ACM updated ' + acm.displayName);
//  }
//
//  // Close db
//  Future close() async {
//    var db = await _getDb();
//    return db.close();
//  }
//
//}