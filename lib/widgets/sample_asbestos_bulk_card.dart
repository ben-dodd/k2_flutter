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
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: const Icon(Icons.whatshot),
      title: Text(widget.doc['jobNumber'] + '-' + widget.doc['sampleNumber'].toString()),
      subtitle: Text(widget.doc['description'] + ': ' + widget.doc['material']),

//      subtitle: Text(widget.sample.description + '(' + widget.sample.material + ')'),
      // Tap -> go through to job task
      onTap: widget.onCardClick,
      // Long tap -> add options to sync or delete
      onLongPress: widget.onCardLongPress,
    );
  }
}