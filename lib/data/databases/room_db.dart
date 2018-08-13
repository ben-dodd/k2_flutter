import 'dart:async';
import 'dart:io';
import 'package:k2e/model/entities/areas/room.dart';
import 'package:k2e/model/entities/areas/super_room.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:k2e/model/jobs/job_header.dart';

class RoomDatabase {
  static final RoomDatabase _RoomDatabase = new RoomDatabase._internal();

  final String tableName = "Room";

  Database db;

  bool didInit = false;

  static RoomDatabase get() {
    return _RoomDatabase;
  }

  RoomDatabase._internal();

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
    String path = join(documentsDirectory.path, "room.db");
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              "CREATE TABLE $tableName ("
                  "uuid STRING PRIMARY KEY,"
                  "displayName TEXT,"
                  "prefix TEXT,"
                  "jobNumber TEXT,"
                  "superRoomUuid TEXT,"
                  "imagePath TEXT,"
                  "hasSynced INTEGER"
                  ")");
        });
    didInit = true;
  }

  /// Get all superrooms linked to the jobNumber
  Future<List<Room>> getRoomsByNumber(String jobNumber) async{
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE jobNumber = "$jobNumber"');
    if(result.length == 0)return null;
    List<Room> rooms = [];
    for(Map<String, dynamic> item in result) {
      rooms.add(new Room.fromJson(item));
    }
    return rooms;
  }

  /// Inserts or replaces the job.
  Future updateRoom(Room room) async {
    var db = await _getDb();
    await db.rawInsert(
        'INSERT OR REPLACE INTO '
            '$tableName(uuid, displayName, prefix, jobNumber, superRoomUuid, imagePath, hasSynced)'
            ' VALUES(?, ?, ?, ?, ?, ?, ?)',
        [room.uuid, room.displayName, room.prefix, room.jobNumber, room.superRoomUuid, room.imagePath, room.hasSynced]);
    print('Room updated ' + room.displayName);
  }

  // Close db
  Future close() async {
    var db = await _getDb();
    return db.close();
  }

}