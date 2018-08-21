import 'package:flutter/material.dart';
import 'package:k2e/model/jobs/job_header.dart';

class WfmJobCard extends StatefulWidget {

  WfmJobCard({
    this.jobHeader,
    @required this.onCardClick
  });

  final JobHeader jobHeader;

  final VoidCallback onCardClick;

  @override
  _WfmJobState createState() => new _WfmJobState();
}

class _WfmJobState extends State<WfmJobCard>{
  Icon icon;
  @override
  Widget build(BuildContext context) {
    if (widget.jobHeader.type.toLowerCase().contains("asbestos")){
      icon = new Icon(Icons.whatshot);
    } else if (widget.jobHeader.type.toLowerCase().contains("meth")){
      icon = new Icon(Icons.lightbulb_outline);
    } else if (widget.jobHeader.type.toLowerCase().contains("noise")){
      icon = new Icon(Icons.hearing);
    } else if (widget.jobHeader.type.toLowerCase().contains("stack")){
      icon = new Icon(Icons.cloud);
    } else if (widget.jobHeader.type.toLowerCase().contains("bio")){
      icon = new Icon(Icons.local_florist);
    } else {
      icon = new Icon(Icons.assignment);
    }
    return new ListTile(
      leading: icon,
      title: Text(widget.jobHeader.jobNumber),
      subtitle: Text(widget.jobHeader.address),
      onTap: widget.onCardClick,
    );
  }
}