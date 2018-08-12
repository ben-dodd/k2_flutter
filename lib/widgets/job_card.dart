import 'package:flutter/material.dart';
import 'package:k2e/model/jobs/job_object.dart';

class JobCard extends StatefulWidget {

  JobCard({
    this.job,
    @required this.onCardClick,
    @required this.onCardLongPress,
  });

  final Job job;

  final VoidCallback onCardClick;
  final VoidCallback onCardLongPress;

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
      // Tap -> go through to job task
      onTap: widget.onCardClick,
      // Long tap -> add options to sync or delete
      onLongPress: widget.onCardLongPress,
    );
  }
}