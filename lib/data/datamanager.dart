// handles all syncing with K2 database

// co-ordinates data between repositories

// Loads new job from remote, including all samples etc.

import 'package:camera/camera.dart';
import 'package:k2e/model/jobheader.dart';
import 'package:k2e/utils/timesheet.dart';

class DataManager {

  static final DataManager _dm = new DataManager._internal();
  // Temp Storage
//  List<JobHeader> myJobCache;
  List<JobHeader> wfmJobCache = new List(); // this holds all jobs gathered from the last WFM api request

  List<CameraDescription> cameras;
  String user;
  String currentJobPath;
  String currentJobNumber;
  List<Map<String, String>> currentJobSamples;
  TimeCounter currentTimeCounter;

  // Autocompletes
  Map<String, dynamic> constants;
  List<String> asbestosmaterials;
  List<String> buildingitems;
  List<String> buildingmaterials;

  static DataManager get() {
    return _dm;
  }

  DataManager._internal(){

  }

//  Future<void> loadJob(String firePath) async {
//    print ('Fire pPath: ' + firePath);
//    JobHeader jobHeader;
//    // Get full Job Header from firestore
//    await Firestore.instance.document(firePath).get().then((fireMap) {
//      jobHeader = JobHeader.fromMap(fireMap.data);
//    });
//    print(job.jobHeader.jobnumber);
//
//    // Get all samples for this job from firestore
//    await Firestore.instance.collection('samplesasbestosbulk').where('jobnumber',isEqualTo: jobHeader.jobnumber).getDocuments().then((fireSamples) {
//      for (DocumentSnapshot samples in fireSamples.documents){
//        job.asbestosBulkSamples.add(new SampleAsbestosBulk().fromMap(samples.data));
//      }
//    });
//    print('List length: ' + job.asbestosBulkSamples.length.toString());
////    job.asbestosBulkSamples = await sampleAsbestosBulkRepo.getSamplesByJobNumber(jobHeader.jobnumber);
//    if (job.asbestosBulkSamples == null) { job.asbestosBulkSamples = []; }
////    job.rooms = await roomRepo.getRoomsByJobNumber(jobHeader.jobnumber);
////    job.superRooms = await superRoomRepo.getSuperRoomsByJobNumber(jobHeader.jobnumber);
//    job.highestSampleNumber = getHighestSampleNumber(job);
//    currentJob = job;
//    return;
//  }

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

//  int getHighestSampleNumber(Job job) {
//    int highestSampleNumber = 0;
//    if (job.asbestosBulkSamples.length > 0) {
//      for (SampleAsbestosBulk sample in job.asbestosBulkSamples) {
//        if (sample.sampleNumber > highestSampleNumber) {
//          highestSampleNumber = sample.sampleNumber;
//        }
//      }
//    }
//    if (job.asbestosAirSamples.length > 0) {
//      for (SampleAsbestosAir sample in job.asbestosAirSamples) {
//        int sampleNumber = int.tryParse(sample.sampleNumber) ?? 0;
//        if (sampleNumber > highestSampleNumber) {
//          highestSampleNumber = sampleNumber;
//        }
//      }
//    }
//    return highestSampleNumber;
//  }

  // Iterates through your jobs and syncs each one
//  Future<void> syncAllJobs() async {
//    jobHeaderRepo.getMyJobs().then((jobs) {
//      for (JobHeader job in jobs) {
//        // Add updating message that indicates how the syncing is going
//        // Iterate through all jobs and add data first, then go through them again and update images
//        jobHeaderRepo.getRemoteJobModifiedDate(job.jobnumber).then((response) {
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
