import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/model/samples/sample_asbestos_bulk.dart';

class SampleAsbestosBulkCard extends StatefulWidget {

  SampleAsbestosBulkCard({
    this.doc,
    @required this.onCardClick,
    @required this.onCardLongPress,
  });

  final DocumentSnapshot doc;
//  final SampleAsbestosBulk sample;

  final VoidCallback onCardClick;
  final VoidCallback onCardLongPress;

  @override
  _SampleAsbestosBulkCardState createState() => new _SampleAsbestosBulkCardState();

}

class _SampleAsbestosBulkCardState extends State<SampleAsbestosBulkCard>{
  String jobNumber;
  String sampleNumber;
  String description;
  String material;
  @override
  Widget build(BuildContext context) {
    // todo is there a better way to assert this stuff
    if (widget.doc['jobNumber'] == null) {
      jobNumber = 'AS******';
    } else {
      jobNumber = widget.doc['jobNumber'];
    }
    if (widget.doc['sampleNumber'] == null) {
      sampleNumber = '0';
    } else {
      sampleNumber = widget.doc['sampleNumber'];
    }
    if (widget.doc['description'] == null) {
      description = 'No description';
    } else {
      description = widget.doc['description'];
    }
    if (widget.doc['material'] == null) {
      material = 'Undefined material';
    } else {
      material = widget.doc['material'];
    }

    return new ListTile(
      leading: const Icon(Icons.whatshot),
      title: Text(jobNumber + '-' + sampleNumber),
      subtitle: Text(description + ': ' + material),

//      subtitle: Text(widget.sample.description + '(' + widget.sample.material + ')'),
      // Tap -> go through to job task
      onTap: widget.onCardClick,
      // Long tap -> add options to sync or delete
      onLongPress: widget.onCardLongPress,
    );
  }
}