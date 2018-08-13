// handles all syncing with K2 database

// co-ordinates data between repositories

// Loads new job from remote, including all samples etc.

import 'dart:async';

import 'package:k2e/data/repos/job_repo.dart';
import 'package:k2e/model/entities/areas/room.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/model/jobs/job_header.dart';

class DataManager {

  static final DataManager _dm = new DataManager._internal();

  // REPOS
  JobRepo jobRepo;

  Job currentJob;
  Room currentRoom;

  static DataManager get() {
    return _dm;
  }

  DataManager._internal(){

  }

  Future init() async {
    await jobRepo.init();
    return true;
  }

  Future<void> loadJob(JobHeader jobHeader) async {
    Job job = new Job(jobHeader);
  }
}
