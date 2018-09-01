//import 'dart:async';
//
//import 'package:k2e/data/databases/room_db.dart';
//import 'package:k2e/model/entities/areas/room.dart';
//
//final int NO_INTERNET = 404;
//
//class RoomRepo {
//
//  static final RoomRepo _repo = new RoomRepo._internal();
//
//  RoomDatabase database;
//
//  static RoomRepo get() {
//    return _repo;
//  }
//
//  RoomRepo._internal() {
//    database = RoomDatabase.get();
//  }
//
//  Future init() async{
//    return await database.init();
//  }
//  /// Get all rooms related to job
//  Future<List<Room>> getRoomsByJobNumber(String jobNumber) async {
//    return database.getRoomsByJobNumber(jobNumber);
//  }
//
//  // Adds new room, or updates if already exists
//  Future<void> updateJob(Room room) async {
//    await database.updateRoom(room);
//  }
//
//  // Closes db
//  Future close() async {
//    return database.close();
//  }
//}