import 'package:meta/meta.dart';

class Job {
  static final db_job_number = "jobNumber";
  static final db_address = "address";
  static final db_description = "description";
  static final db_client_name = "clientName";
  static final db_state = "state";
  static final db_type = "type";
  static final db_status = "status"; // Is this just an API thing, probably don't need it in the DB

  String
      jobNumber,
      address,
      description,
      clientName,
      state,
      type,
      status;

  Job({
    @required this.jobNumber,
    this.address,
    this.description,
    this.clientName,
    this.state,
    this.type,
    this.status,
  });

  // Get from Database
  Job.fromMap(Map<String, dynamic> map): this(
    jobNumber: map[db_job_number],
    address: map[db_address],
    description: map[db_description],
    clientName: map[db_client_name],
    state: map[db_state],
    type: map[db_type],
    status: map[db_status],
  );

  // Load to Database
  Map<String, dynamic> toMap() {
    return {
      db_job_number: jobNumber,
      db_address: address,
      db_description: description,
      db_client_name: clientName,
      db_state: state,
      db_type: type,
      db_status: status,
    };
  }
}