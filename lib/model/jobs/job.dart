// Master job class for holding all information on an asbestos job
import 'package:k2e/data/datamanager.dart';
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

  int highestSampleNumber = 0; // the highest sample number in the current job

  Job(JobHeader job) {
    this.jobHeader = job;
    rooms = new List();
    superRooms = new List();
    acms = new List();
    asbestosBulkSamples = new List();
    asbestosAirSamples = new List();
    items = new List();
    materialNotes = new List();
  }
}