//import 'dart:async';
//
//import 'package:k2e/data/databases/acm_db.dart';
//import 'package:k2e/model/entities/materials/acm.dart';
//
//final int NO_INTERNET = 404;
//
//class AcmRepo {
//
//  static final AcmRepo _repo = new AcmRepo._internal();
//
//  AcmDatabase database;
//
//  static AcmRepo get() {
//    return _repo;
//  }
//
//  AcmRepo._internal() {
//    database = AcmDatabase.get();
//  }
//
//  Future init() async{
//    return await database.init();
//  }
//  /// Get all rooms related to job
//  Future<List<ACM>> getAcmByJobNumber(String jobNumber) async {
//    return database.getAcmByJobNumber(jobNumber);
//  }
//
//  // Adds new room, or updates if already exists
//  Future<void> updateACM(ACM acm) async {
//    await database.updateAcm(acm);
//  }
//
//  // Closes db
//  Future close() async {
//    return database.close();
//  }
//}