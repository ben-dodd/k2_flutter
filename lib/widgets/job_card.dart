import 'package:flutter/material.dart';
import 'package:k2e/model/jobs/job_header.dart';

class JobCard extends StatefulWidget {

  JobCard({
    this.jobHeader,
    @required this.onCardClick,
    @required this.onCardLongPress,
  });

  final JobHeader jobHeader;

  final VoidCallback onCardClick;
  final VoidCallback onCardLongPress;

  @override
  _JobCardState createState() => new _JobCardState();

}

class _JobCardState extends State<JobCard>{
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
      // Tap -> go through to job task
      onTap: widget.onCardClick,
      // Long tap -> add options to sync or delete
      onLongPress: widget.onCardLongPress,
    );
  }
}