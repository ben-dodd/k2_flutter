import 'package:meta/meta.dart';

class JobHeader {
  String
  jobnumber,
  address,
  description,
  clientname,
  state,
  type;

  JobHeader({
    @required this.jobnumber,
    this.address,
    this.description,
    this.clientname,
    this.state,
    this.type,
  });

  static JobHeader fromMap(Map<String, dynamic> map){
    JobHeader jobHeader = new JobHeader(
      jobnumber: map['jobNumber'],
      address: map['address'],
      description: map['description'],
      clientname: map['clientName'],
      state: map['state'],
      type: map['type'],
    );
    return jobHeader;
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = new Map();
    map['jobnumber'] = jobnumber;
    map['address'] = address;
    map['description'] = description;
    map['clientname'] = clientname;
    map['state'] = state;
    map['type'] = type;
    return map;
  }
}