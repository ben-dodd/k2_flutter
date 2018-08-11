import 'package:flutter/material.dart';
import 'package:k2e/model/jobs/job_object.dart';

class JobCard extends StatefulWidget {

  JobCard({
    this.job,
    @required this.onCardClick
  });

  final Job job;

  final VoidCallback onCardClick;

  @override
  _JobCardState createState() => new _JobCardState();
}

class _JobCardState extends State<JobCard>{
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: const Icon(Icons.whatshot),
      title: Text(widget.job.jobNumber),
      subtitle: Text(widget.job.address),
      onTap: widget.onCardClick,
    );
  }
}