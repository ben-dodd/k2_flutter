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
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: const Icon(Icons.lightbulb_outline),
      title: Text(widget.jobHeader.jobNumber),
      subtitle: Text(widget.jobHeader.address),
      onTap: widget.onCardClick,
    );
  }
}