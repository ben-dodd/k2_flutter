import 'package:meta/meta.dart';

class JobHeader {
  String jobNumber, address, description, clientName, state, type;

  JobHeader({
    @required this.jobNumber,
    this.address,
    this.description,
    this.clientName,
    this.state,
    this.type,
  });

  static JobHeader fromMap(Map<String, dynamic> map) {
    JobHeader jobHeader = new JobHeader(
      jobNumber: map['jobNumber'],
      address: map['address'],
      description: map['description'],
      clientName: map['clientName'],
      state: map['state'],
      type: map['type'],
    );
    return jobHeader;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map();
    map['jobNumber'] = jobNumber;
    map['address'] = address;
    map['description'] = description;
    map['clientName'] = clientName;
    map['state'] = state;
    map['type'] = type;
    return map;
  }
}
