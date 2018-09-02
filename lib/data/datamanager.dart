// handles all syncing with K2 database

// co-ordinates data between repositories

// Loads new job from remote, including all samples etc.

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:k2e/model/entities/areas/room.dart';
import 'package:k2e/model/samples/sample_asbestos_air.dart';
import 'package:k2e/model/samples/sample_asbestos_bulk.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/model/jobs/job_header.dart';
import 'package:validator/validator.dart';

class DataManager {

  static final DataManager _dm = new DataManager._internal();

  // REPOS
//  JobHeaderRepo jobHeaderRepo;
//  SampleAsbestosBulkRepo sampleAsbestosBulkRepo;
//  RoomRepo roomRepo;
//  SuperRoomRepo superRoomRepo;

  // Temp Storage
  List<JobHeader> myJobCache;
  Job currentJob;   // this holds the current job being worked on
//  List<JobHeader> wfmJobCache = new List(); // this holds all jobs gathered from the last WFM api request
//  List<JobHeader> myJobCache = new List(); // this holds all jobs in the local database
  Room currentRoom; // either the Room that was last added or the room currently being edited
  SampleAsbestosBulk currentAsbestosBulkSample;
  List<CameraDescription> cameras;
  String user;
  String currentJobPath;

  static DataManager get() {
    return _dm;
  }

  DataManager._internal(){
//    jobHeaderRepo = JobHeaderRepo.get();
//    sampleAsbestosBulkRepo = SampleAsbestosBulkRepo.get();
//    roomRepo = RoomRepo.get();
//    superRoomRepo = SuperRoomRepo.get();
  }

//  Future init() async {
////    await jobHeaderRepo.init();
////    await sampleAsbestosBulkRepo.init();
////    await roomRepo.init();
////    await superRoomRepo.init();
//    return true;
//  }

  Future<void> loadJob(String firePath) async {
    print ('Fire pPath: ' + firePath);
    JobHeader jobHeader;
    // Get full Job Header from firestore
    await Firestore.instance.document(firePath).get().then((fireMap) {
      jobHeader = JobHeader.fromMap(fireMap.data);
    });
    Job job = new Job(jobHeader);
    print(job.jobHeader.jobNumber);

    // Get all samples for this job from firestore
    await Firestore.instance.collection('samplesasbestosbulk').where('jobNumber',isEqualTo: jobHeader.jobNumber).getDocuments().then((fireSamples) {
      for (DocumentSnapshot samples in fireSamples.documents){
        job.asbestosBulkSamples.add(new SampleAsbestosBulk().fromMap(samples.data));
      }
    });
    print('List length: ' + job.asbestosBulkSamples.length.toString());
//    job.asbestosBulkSamples = await sampleAsbestosBulkRepo.getSamplesByJobNumber(jobHeader.jobNumber);
    if (job.asbestosBulkSamples == null) { job.asbestosBulkSamples = []; }
//    job.rooms = await roomRepo.getRoomsByJobNumber(jobHeader.jobNumber);
//    job.superRooms = await superRoomRepo.getSuperRoomsByJobNumber(jobHeader.jobNumber);
    job.highestSampleNumber = getHighestSampleNumber(job);
    currentJob = job;
    return;
  }

//  Future<void> updateSampleAsbestosBulk(SampleAsbestosBulk sample) async {
//    sampleAsbestosBulkRepo.updateSample(sample);
//    bool itemFound = false;
//    for (SampleAsbestosBulk sampleItem in currentJob.asbestosBulkSamples){
//      if(sampleItem.uuid == sample.uuid){
//        // update sample
//        sampleItem = sample;
//        itemFound = true;
//      }
//    }
//    if (!itemFound) {
//      currentJob.asbestosBulkSamples.add(sample);
//      sampleAsbestosBulkRepo.updateSample(sample);
//      await Firestore.instance.collection('samplesasbestosbulk').add(sample.toJson());
//    }
//    currentAsbestosBulkSample = null;
//  }

  int getHighestSampleNumber(Job job) {
    int highestSampleNumber = 0;
    if (job.asbestosBulkSamples.length > 0) {
      for (SampleAsbestosBulk sample in job.asbestosBulkSamples) {
        if (sample.sampleNumber > highestSampleNumber) {
          highestSampleNumber = sample.sampleNumber;
        }
      }
    }
    if (job.asbestosAirSamples.length > 0) {
      for (SampleAsbestosAir sample in job.asbestosAirSamples) {
        if (isNumeric(sample.sampleNumber)) {
          int sampleNumber = toInt(sample.sampleNumber);
          if (sampleNumber > highestSampleNumber) {
            highestSampleNumber = sampleNumber;
          }
        }
      }
    }
    return highestSampleNumber;
  }

  // Iterates through your jobs and syncs each one
//  Future<void> syncAllJobs() async {
//    jobHeaderRepo.getMyJobs().then((jobs) {
//      for (JobHeader job in jobs) {
//        // Add updating message that indicates how the syncing is going
//        // Iterate through all jobs and add data first, then go through them again and update images
//        jobHeaderRepo.getRemoteJobModifiedDate(job.jobNumber).then((response) {
//          // check if modified date on server is newer than this job
//        });
//      }
//      // Now add all the images in background task (show in Android notification drawer)
//      for (JobHeader job in jobs) {
//
//      }
//    });
//  }
}
