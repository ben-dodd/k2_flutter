// Master job class for holding all information on an asbestos job
import 'dart:async';

import 'package:k2e/model/entities/areas/room.dart';
import 'package:k2e/model/entities/areas/super_room.dart';
import 'package:k2e/model/entities/materials/acm.dart';
import 'package:k2e/model/entities/materials/item.dart';
import 'package:k2e/model/entities/materials/material_note.dart';
import 'package:k2e/model/entities/samples/sample_asbestos_air.dart';
import 'package:k2e/model/entities/samples/sample_asbestos_bulk.dart';
import 'package:k2e/model/jobs/job_header.dart';

class Job {
  JobHeader jobHeader;
  List<Room> rooms;
  List<SuperRoom> superRooms;
  List<ACM> acms;
  List<SampleAsbestosBulk> asbestosBulkSamples;
  List<SampleAsbestosAir> asbestosAirSamples;
  List<Item> items;
  List<MaterialNote> materialNotes;

  Job(JobHeader job) {
    this.jobHeader = job;
  }
}

// Loads Asbestos Job
Future loadJob() async {

}