import 'package:flutter/material.dart';
import 'package:k2e/model/jobs/job_object.dart';

class WfmJobCard extends StatefulWidget {

  WfmJobCard({
    this.job,
    @required this.onCardClick
  });

  final Job job;

  final VoidCallback onCardClick;

  @override
  _WfmJobState createState() => new _WfmJobState();
}

class _WfmJobState extends State<WfmJobCard>{
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: const Icon(Icons.lightbulb_outline),
      title: Text(widget.job.jobNumber),
      subtitle: Text(widget.job.address),
      onTap: widget.onCardClick,
    );
  }
}