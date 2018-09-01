//import 'dart:async';
//import 'dart:io';
//
//import 'package:k2e/model/entities/areas/super_room.dart';
//import 'package:path/path.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:sqflite/sqflite.dart';
//
//class SuperRoomDatabase {
//  static final SuperRoomDatabase _superRoomDatabase = new SuperRoomDatabase._internal();
//
//  final String tableName = "SuperRoom";
//
//  Database db;
//
//  bool didInit = false;
//
//  static SuperRoomDatabase get() {
//    return _superRoomDatabase;
//  }
//
//  SuperRoomDatabase._internal();
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
//    String path = join(documentsDirectory.path, "superroom.db");
//    db = await openDatabase(path, version: 1,
//        onCreate: (Database db, int version) async {
//          // When creating the db, create the table
//          await db.execute(
//              "CREATE TABLE $tableName ("
//                  "uuid STRING PRIMARY KEY,"
//                  "displayName TEXT,"
//                  "prefix TEXT,"
//                  "jobNumber TEXT,"
//                  "hasSynced INTEGER"
//                  ")");
//        });
//    didInit = true;
//  }
//
//  /// Get all superrooms linked to the jobNumber
//  Future<List<SuperRoom>> getSuperRoomsByJobNumber(String jobNumber) async{
//    var db = await _getDb();
//    var result = await db.rawQuery('SELECT * FROM $tableName WHERE jobNumber = "$jobNumber"');
//    if(result.length == 0)return null;
//    List<SuperRoom> superRooms = [];
//    for(Map<String, dynamic> item in result) {
//      superRooms.add(new SuperRoom.fromJson(item));
//    }
//    return superRooms;
//  }
//
//  /// Inserts or replaces the job.
//  Future updateSuperRoom(SuperRoom superRoom) async {
//    var db = await _getDb();
//    await db.rawInsert(
//        'INSERT OR REPLACE INTO '
//            '$tableName(uuid, displayName, prefix, jobNumber, hasSynced)'
//            ' VALUES(?, ?, ?, ?, ?)',
//        [superRoom.uuid, superRoom.displayName, superRoom.prefix, superRoom.jobNumber, superRoom.hasSynced]);
//    print('SuperRoom updated ' + superRoom.displayName);
//  }
//
//  // Close db
//  Future close() async {
//    var db = await _getDb();
//    return db.close();
//  }
//
//}