//import 'dart:async';
//
//import 'package:k2e/data/databases/superroom_db.dart';
//import 'package:k2e/model/entities/areas/super_room.dart';
//
//final int NO_INTERNET = 404;
//
//class SuperRoomRepo {
//
//  static final SuperRoomRepo _repo = new SuperRoomRepo._internal();
//
//  SuperRoomDatabase database;
//
//  static SuperRoomRepo get() {
//    return _repo;
//  }
//
//  SuperRoomRepo._internal() {
//    database = SuperRoomDatabase.get();
//  }
//
//  Future init() async{
//    return await database.init();
//  }
//  /// Get all rooms related to job
//  Future<List<SuperRoom>> getSuperRoomsByJobNumber(String jobNumber) async {
//    return database.getSuperRoomsByJobNumber(jobNumber);
//  }
//
//  // Adds new room, or updates if already exists
//  Future<void> updateSuperRoom(SuperRoom superRoom) async {
//    await database.updateSuperRoom(superRoom);
//  }
//
//  // Closes db
//  Future close() async {
//    return database.close();
//  }
//}